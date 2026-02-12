// File: lib/features/calendar/presentation/widgets/calendars/month_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/utils/task_utils.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/task_summary_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_app/features/calendar/presentation/utils/rrule_utils.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/color_selector.dart';

class MonthView extends ConsumerStatefulWidget {
  final List<Task> tasks;
  final CalendarController calendarController;
  final DateTime selectedDate;
  final ValueNotifier<DateTime> dateNotifier;
  final Function(ViewChangedDetails) onViewChanged;
  final Function(Task) onTaskTap;

  const MonthView({
    super.key,
    required this.tasks,
    required this.calendarController,
    required this.selectedDate,
    required this.dateNotifier,
    required this.onViewChanged,
    required this.onTaskTap,
  });

  @override
  ConsumerState<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends ConsumerState<MonthView> {
  // 1. Use the inclusive data source
  late MonthDataSource _dataSource;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isInitialized) {
      _dataSource = MonthDataSource(widget.tasks, isDark);
      _isInitialized = true;
    } else {
      _dataSource.updateData(widget.tasks, isDark);
    }
  }

  @override
  void didUpdateWidget(MonthView oldWidget) {
    super.didUpdateWidget(oldWidget);

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
    final DateTime now = DateTime.now();

    if (!_isInitialized) return const SizedBox();

    return SfCalendar(
      view: CalendarView.month,
      controller: widget.calendarController,
      headerHeight: 0,
      backgroundColor: colorScheme.surface,
      cellBorderColor: Colors.transparent,
      dataSource: _dataSource,
      onViewChanged: widget.onViewChanged,

      // 2. Configure Settings: Show 3 items, then "+X more"
      monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        appointmentDisplayCount: 3, 
        showAgenda: false,
      ),

      // 3. Custom Appointment Builder (Your preferred styling)
      appointmentBuilder: (context, details) {
        final Appointment appointment = details.appointments.first;
        
        final task = widget.tasks.firstWhere(
          (t) => t.id == appointment.id,
          orElse: () => Task(id: "temp", title: "", startTime: DateTime.now()),
        );

        if (task.id == "temp") return const SizedBox();

        final bool isCompleted = task.status == TaskStatus.completed;
        final Color textColor = ThemeData.estimateBrightnessForColor(appointment.color) == Brightness.light
            ? Colors.black
            : Colors.white;

        return Container(
          decoration: BoxDecoration(
            // Lighten background if completed
            color: isCompleted ? appointment.color.withOpacity(0.4) : appointment.color,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          alignment: Alignment.centerLeft,
          child: Text(
            appointment.subject,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isCompleted ? textColor.withOpacity(0.6) : textColor,
              // Apply Strikethrough
              decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
              // Apply Italic
              fontStyle: isCompleted ? FontStyle.italic : FontStyle.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },

      monthCellBuilder: (context, details) {
        final bool isToday = DateUtils.isSameDay(details.date, now);
        final bool isCurrentMonth =
            details.date.month ==
            (widget.calendarController.displayDate?.month ?? now.month);

        return Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withOpacity(isDark ? 0.03 : 0.05),
            borderRadius: BorderRadius.circular(8),
            border: DateUtils.isSameDay(details.date, widget.selectedDate)
                ? Border.all(
                    color: colorScheme.primary.withOpacity(0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isToday ? colorScheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    details.date.day.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? colorScheme.onPrimary
                          : (isCurrentMonth
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withOpacity(0.2)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },

      onTap: (details) {
        if (details.targetElement == CalendarElement.calendarCell ||
            details.targetElement == CalendarElement.appointment) {
          final date = details.date!;
          
          // If tapped on an appointment directly, trigger task tap
          if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
             final Appointment selectedAppt = details.appointments!.first;
             try {
                final tappedTask = widget.tasks.firstWhere((t) => t.id == selectedAppt.id);
                widget.onTaskTap(tappedTask);
                return;
             } catch (e) {
               // Fallback if not found
             }
          }

          final range = date.range(CalendarScope.day);
          
          // Show ALL tasks for the day in the bottom sheet (Inclusive)
          final dayTasks = widget.tasks
              .where(
                (t) =>
                    t.startTime != null &&
                    t.status != TaskStatus.pending && 
                    TaskUtils.validTaskModelForDate(t, range.start, range.end),
              )
              .toList();
              
          if (dayTasks.isNotEmpty) {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => TaskSummaryView(
                date: date,
                tasks: dayTasks,
                onTaskTap: widget.onTaskTap,
              ),
            );
          }
        }
      },
    );
  }
}

// --- 4. DEDICATED MONTH DATA SOURCE ---
// Includes: Tasks, Events, Birthdays, All-Day
class MonthDataSource extends CalendarDataSource {
  MonthDataSource(List<Task> tasks, bool isDark) {
    _buildAppointments(tasks, isDark);
  }

  void updateData(List<Task> tasks, bool isDark) {
    _buildAppointments(tasks, isDark);
    notifyListeners(CalendarDataSourceAction.reset, appointments!);
  }

  void _buildAppointments(List<Task> tasks, bool isDark) {
    // Filter: Allow Birthdays + Scheduled Non-Pending Tasks
    final visibleTasks = tasks.where((t) {
      if (t.startTime == null) return false;
      if (t.type == TaskType.birthday) {
        print('✅ DEBUG: Found birthday "${t.title}" with startTime: ${t.startTime}, recurrenceRule: ${t.recurrenceRule}');
        return true;
      }
      return t.status != TaskStatus.pending;
    }).toList();
    print('📊 DEBUG: MonthDataSource has ${tasks.length} total tasks, ${visibleTasks.length} visible tasks');

    appointments = visibleTasks.map((task) {
      final Color displayColor = _resolveColor(task.colorValue, isDark);
      final bool isCompleted = task.status == TaskStatus.completed;

      DateTime endTime = task.endTime ?? task.startTime!.add(const Duration(hours: 1));
      
      // Visual fix: ensure bars are visible
      if (endTime.difference(task.startTime!).inMinutes < 30) {
        endTime = task.startTime!.add(const Duration(minutes: 30));
      }

      // --- CRITICAL FIX FOR BIRTHDAYS ---
      // If it's a birthday, we MUST ensure it has a yearly recurrence rule with month/day components.
      // Otherwise, if the start date is in 1990, it won't show up in 2026.
      String? rRule = RRuleUtils.sanitizeRRule(task.recurrenceRule);
      if (task.type == TaskType.birthday) {
        if (rRule == null || rRule.isEmpty || rRule == 'None') {
          rRule = 'FREQ=YEARLY;BYMONTH=${task.startTime!.month};BYMONTHDAY=${task.startTime!.day}';
          print('⚠️ DEBUG: Birthday "${task.title}" had empty recurrenceRule, setting to: $rRule');
        } else {
          print('✅ DEBUG: Birthday "${task.title}" has recurrenceRule: $rRule');
        }
      }

      return Appointment(
        id: task.id,
        subject: task.title,
        startTime: task.startTime!,
        endTime: endTime,
        notes: task.description,
        color: isCompleted ? displayColor.withOpacity(0.4) : displayColor,
        // Force AllDay so it renders as a bar in Month View
        isAllDay: true, 
        recurrenceRule: rRule,
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