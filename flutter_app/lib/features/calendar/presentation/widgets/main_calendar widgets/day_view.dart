import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/appointment_card.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/color_selector.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/main_calendar%20widgets/calendar_builder.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
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
                    onTaskTap: onTaskTap, // This passes the callback to the builder
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SfCalendar(
            view: CalendarView.day,
            controller: calendarController,
            headerHeight: 0,
            viewHeaderHeight: 0,
            backgroundColor: colorScheme.surface,
            cellBorderColor: Colors.transparent,
            dataSource: TaskDataSource(
              tasks.where((t) => !t.isAllDay && t.type != TaskType.birthday && t.startTime != null).toList(),
              context,
            ),
            appointmentBuilder: (context, details) {
              return AppointmentCard(appointment: details.appointments.first);
            },
            specialRegions: greyBlocks,
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
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              timeIntervalHeight: 80,
            ),
          ),
        ),
      ],
    );
  }
}

/// Extracted DataSource so it can be reused by Week/Month views later
class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Task> tasks, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    appointments = tasks.map((task) {
      final Color displayColor = _resolveColor(task.colorValue, isDark);

      return Appointment(
        id: task.id,
        subject: task.title,
        startTime: task.startTime!,
        endTime: task.endTime!,
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