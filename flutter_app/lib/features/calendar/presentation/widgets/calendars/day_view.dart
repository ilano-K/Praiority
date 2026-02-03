import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/appointment_card.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/color_selector.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/calendar_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DayView extends ConsumerWidget {
  final List<Task> tasks;
  final CalendarController calendarController;
  final DateTime selectedDate;
  final Function(ViewChangedDetails) onViewChanged;
  final Function(Task) onTaskTap;
  final VoidCallback onDateTap;
  final List<TimeRegion> greyBlocks;

  const DayView({
    super.key,
    required this.tasks,
    required this.calendarController,
    required this.selectedDate,
    required this.onViewChanged,
    required this.onTaskTap,
    required this.onDateTap,
    required this.greyBlocks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ACCESS YOUR CUSTOM THEME COLORS
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // --- HEADER SECTION ---
        Container(
          // Using surface (Light: FFFFFF, Dark: 0C0C0C)
          color: colorScheme.surface, 
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalendarBuilder.buildDateSidebar(
                colorScheme: colorScheme,
                selectedDate: selectedDate,
                onTap: onDateTap,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 12, bottom: 8),
                  child: CalendarBuilder.buildAllDayList(
                    tasks: tasks,
                    isDark: isDark,
                    onTaskTap: onTaskTap,
                    selectedDate: selectedDate,
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- CALENDAR GRID SECTION ---
        Expanded(
          child: SfCalendar(
            view: CalendarView.day,
            controller: calendarController,
            headerHeight: 0,
            viewHeaderHeight: 0,
            backgroundColor: colorScheme.surface, // Uses surface
            cellBorderColor: Colors.transparent, 
            
            dataSource: TaskDataSource(
              tasks.where((t) => 
                !t.isAllDay && 
                t.type != TaskType.birthday && 
                t.startTime != null
              ).toList(),
              context,
            ),

            // --- APPOINTMENT BUILDER ---
            appointmentBuilder: (context, details) {
            final appointment = details.appointments.first;
            final task = tasks.firstWhere((t) => t.id == appointment.id);
            final bool isTaskOnly = task.type == TaskType.task;

            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: appointment.color,
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
                            // FIX: Use onSurface for Black in Light Mode, White in Dark Mode
                            color: colorScheme.onSurface, 
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
                                // FIX: Use onSurface with opacity for the description
                                color: colorScheme.onSurface.withOpacity(0.7),
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
                        color: _getPriorityColor(task.priority, isDark),
                      ),
                    ),
                ],
              ),
            );
          },

            // --- BACKGROUND SLOTS (Rounded blocks using secondary color) ---
            specialRegions: greyBlocks,
            timeRegionBuilder: (BuildContext context, TimeRegionDetails details) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  // Using secondary (Light: DFDFDF, Dark: 3A3A3A)
                  color: colorScheme.secondary.withOpacity(isDark ? 0.5 : 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.onSurface.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              );
            },

            onViewChanged: onViewChanged,
            onTap: (CalendarTapDetails details) {
              if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
                final Appointment selectedAppt = details.appointments!.first;
                final tappedTask = tasks.firstWhere((t) => t.id == selectedAppt.id);
                onTaskTap(tappedTask);
              }
            },

            timeSlotViewSettings: TimeSlotViewSettings(
            timeRulerSize: 60,
              timeTextStyle: TextStyle(
                // FIX: This ensures the 1:00 PM / 2:00 PM text is Black (0xFF000000)
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
  
    Color _getPriorityColor(TaskPriority priority, bool isDark) {
  switch (priority) {
    case TaskPriority.high:
      // Red: Brighter for Dark, deeper for Light
      return isDark ? const Color.fromARGB(255, 181, 0, 0) : const Color(0xFFD32F2F); 
    case TaskPriority.medium:
      // Orange: Vibrant for Dark, more "Amber" for Light to avoid washing out
      return isDark ? const Color.fromARGB(255, 253, 144, 0) : Colors.orange.shade800;
    case TaskPriority.low:
      // Green: GreenAccent for Dark, standard Green for Light
      return isDark ? const Color.fromARGB(255, 0, 218, 112) : Colors.green.shade700;
    default:
      return isDark ? Colors.white70 : Colors.black54;
  }
}
}

/// TaskDataSource: Maps your domain Task entity to Syncfusion Appointment objects
class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Task> tasks, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    appointments = tasks.map((task) {
        final Color displayColor = _resolveColor(task.colorValue, isDark);
        
        DateTime visualEndTime = task.endTime!;
        final duration = task.endTime!.difference(task.startTime!);
        
        // --- THE BUFFER ---
        // Ensure every task has at least 20 minutes of height 
        // so the Stack (Title + Map Icon) doesn't overlap or hide.
        if (duration.inMinutes < 20) {
          visualEndTime = task.startTime!.add(const Duration(minutes: 20));
        }

        return Appointment(
          id: task.id,
          subject: task.title,
          startTime: task.startTime!,
          endTime: visualEndTime, // This makes the card tall enough for the icon
          notes: task.status == TaskStatus.completed 
              ? "[COMPLETED]${task.description ?? ''}" 
              : task.description,
          color: displayColor,
          isAllDay: task.isAllDay,
          recurrenceRule: task.recurrenceRule,
        );
      }).toList();
  }

  Color _resolveColor(int? savedHex, bool isDark) {
    if (savedHex == null) {
      return isDark ? appEventColors[0].dark : appEventColors[0].light;
    }
    try {
      final paletteMatch = appEventColors.firstWhere(
        (c) => c.light.value == savedHex || c.dark.value == savedHex,
      );
      return isDark ? paletteMatch.dark : paletteMatch.light;
    } catch (e) {
      return Color(savedHex);
    }
  }
}