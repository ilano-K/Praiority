// File: lib/features/calendar/presentation/widgets/calendars/day_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/calendar_builder.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/sheets/add_task_sheet.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/color_selector.dart';

class DayView extends ConsumerStatefulWidget {
  final List<Task> tasks;
  final CalendarController calendarController;
  final DateTime selectedDate;

  // FIX: Accept Notifier
  final ValueNotifier<DateTime> dateNotifier;

  final Function(ViewChangedDetails) onViewChanged;
  final Function(Task) onTaskTap;
  final VoidCallback onDateTap;
  final List<TimeRegion> greyBlocks;

  const DayView({
    super.key,
    required this.tasks,
    required this.calendarController,
    required this.selectedDate,
    required this.dateNotifier,
    required this.onViewChanged,
    required this.onTaskTap,
    required this.onDateTap,
    required this.greyBlocks,
  });

  @override
  ConsumerState<DayView> createState() => _DayViewState();
}

class _DayViewState extends ConsumerState<DayView> {
  late TaskDataSource _dataSource;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isInitialized) {
      _dataSource = TaskDataSource(widget.tasks, isDark);
      _isInitialized = true;
    } else {
      _dataSource.updateData(widget.tasks, isDark);
    }
  }

  @override
  void didUpdateWidget(DayView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update data if the task list content actually changed
    if (oldWidget.tasks != widget.tasks) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      if (_isInitialized) {
        _dataSource.updateData(widget.tasks, isDark);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isInitialized) return const SizedBox();

    return Column(
      children: [
        // --- HEADER (Rebuilds via Notifier) ---
        Container(
          color: colorScheme.surface,
          width: double.infinity,
          child: ValueListenableBuilder<DateTime>(
            valueListenable: widget.dateNotifier,
            builder: (context, date, _) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CalendarBuilder.buildDateSidebar(
                    colorScheme: colorScheme,
                    selectedDate: date,
                    onTap: widget.onDateTap,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 12,
                        right: 12,
                        bottom: 8,
                      ),
                      child: CalendarBuilder.buildAllDayList(
                        tasks: widget.tasks,
                        isDark: isDark,
                        onTaskTap: widget.onTaskTap,
                        selectedDate: date,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // --- CALENDAR BODY (Stable) ---
        Expanded(
          child: SfCalendar(
            view: CalendarView.day,
            controller: widget.calendarController,
            headerHeight: 0,
            viewHeaderHeight: 0,
            backgroundColor: colorScheme.surface,
            cellBorderColor: Colors.transparent,

            dataSource: _dataSource,

            // DEBUG: Watch where we scroll
            onViewChanged: (details) {
              if (details.visibleDates.isNotEmpty) {
                print(
                  "DEBUG: [SfCalendar] Scrolled to: ${details.visibleDates.first}",
                );
              }
              widget.onViewChanged(details);
            },

            // --- DEBUG: THE APPOINTMENT BUILDER TRAP ---
            appointmentBuilder: (context, details) {
              final appointment = details.appointments.first;

              // We try to find the actual Task object that matches this appointment ID
              final task = widget.tasks.firstWhere(
                (t) => t.id == appointment.id,
                orElse: () {
                  // !!! TRAP !!!
                  // If this runs, it means Syncfusion has an appointment ID that
                  // DOES NOT EXIST in your current 'widget.tasks' list.
                  // This is why it returns SizedBox and looks "invisible".
                  print(
                    "🚨 MISSING TASK: Syncfusion tried to render ID ${appointment.id}, but it's not in the task list!",
                  );
                  return Task(
                    id: "temp",
                    title: "Missing",
                    startTime: DateTime.now(),
                  );
                },
              );

              if (task.id == "temp") {
                // Return a red box instead of blank so you can SEE if it's missing data vs rendering issue
                return Container(color: Colors.red, width: 20, height: 20);
              }

              return DayAppointmentCard(
                task: task,
                appointment: appointment,
                isDark: isDark,
                colorScheme: colorScheme,
              );
            },

            specialRegions: widget.greyBlocks,
            timeRegionBuilder: (context, details) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(isDark ? 0.5 : 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.onSurface.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              );
            },

            onTap: (CalendarTapDetails details) {
              if (details.targetElement == CalendarElement.appointment &&
                  details.appointments != null) {
                final Appointment selectedAppt = details.appointments!.first;
                final tappedTask = widget.tasks.firstWhere(
                  (t) => t.id == selectedAppt.id,
                );
                widget.onTaskTap(tappedTask);
              } else if (details.targetElement ==
                      CalendarElement.calendarCell &&
                  details.date != null) {
                _showAddTaskSheet(context, details.date!);
              }
            },

            timeSlotViewSettings: TimeSlotViewSettings(
              timeRulerSize: 60,
              timeTextStyle: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              timeIntervalHeight: 120,
              timelineAppointmentHeight: 50,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddTaskSheet(BuildContext context, DateTime tappedTime) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskSheet(initialDate: tappedTime),
    );
  }
}

// ... DayAppointmentCard remains the same ...
class DayAppointmentCard extends StatelessWidget {
  final Task task;
  final Appointment appointment;
  final bool isDark;
  final ColorScheme colorScheme;

  const DayAppointmentCard({
    super.key,
    required this.task,
    required this.appointment,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTaskOnly = task.type == TaskType.task;
    // 1. Check completion status
    final bool isCompleted = task.status == TaskStatus.completed;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        // 2. Lighten background color if completed
        color: isCompleted ? appointment.color.withOpacity(0.5) : appointment.color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.subject,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: colorScheme.onSurface,
                    // 3. Apply Strikethrough & Italic to Title
                    decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    fontStyle: isCompleted ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (appointment.notes != null && appointment.notes!.isNotEmpty)
                  Expanded(
                    child: Text(
                      appointment.notes!,
                      style: TextStyle(
                        fontSize: 10,
                        // 4. Dim the notes color significantly if completed
                        color: isCompleted 
                            ? colorScheme.onSurface.withOpacity(0.5) 
                            : colorScheme.onSurface.withOpacity(0.7),
                        // 5. Apply Strikethrough & Italic to Notes
                        decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                        fontStyle: isCompleted ? FontStyle.italic : FontStyle.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          if (isTaskOnly)
            Positioned(
              top: 2,
              right: 2,
              child: Icon(
                Icons.flag_rounded,
                size: 24,
                // 6. Dim the flag icon if completed
                color: _getPriorityColor(task.priority).withOpacity(isCompleted ? 0.5 : 1.0),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return isDark
            ? const Color.fromARGB(255, 181, 0, 0)
            : const Color(0xFFD32F2F);
      case TaskPriority.medium:
        return isDark
            ? const Color.fromARGB(255, 253, 144, 0)
            : Colors.orange.shade800;
      case TaskPriority.low:
        return isDark
            ? const Color.fromARGB(255, 0, 218, 112)
            : Colors.green.shade700;
      default:
        return isDark ? Colors.white70 : Colors.black54;
    }
  }
}