// File: lib/features/calendar/presentation/pages/week_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/appointment_card.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/color_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'day_view.dart'; // Contains TaskDataSource

class WeekView extends ConsumerWidget {
  final List<Task> tasks;
  final CalendarController calendarController;
  final DateTime selectedDate;
  final Function(ViewChangedDetails) onViewChanged;
  final Function(Task) onTaskTap;
  final VoidCallback onDateTap;
  final List<TimeRegion> greyBlocks;

  const WeekView({
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

    // Calculate the 7 days starting from Sunday
    final DateTime firstDayOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday % 7));
    final List<DateTime> weekDays = List.generate(7, (index) => firstDayOfWeek.add(Duration(days: index)));

    return Column(
      children: [
        // --- ALL DAY & SIDEBAR SECTION (CUSTOM HEADER) ---
        Container(
          color: colorScheme.surface,
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 60), // Fixed width to match the time ruler
              ...weekDays.map((day) {
                final dayTasks = tasks.where((t) {
                  return (t.isAllDay || t.type == TaskType.birthday) &&
                         t.startTime != null &&
                         DateUtils.isSameDay(t.startTime!, day);
                }).toList();

                return Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('E').format(day),
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              DateFormat('d').format(day),
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildDayTaskList(dayTasks, isDark, onTaskTap),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // --- MAIN CALENDAR SECTION ---
        Expanded(
          child: SfCalendar(
            view: CalendarView.week,
            controller: calendarController,
            headerHeight: 0,
            viewHeaderHeight: 0, 
            backgroundColor: colorScheme.surface,
            cellBorderColor: Colors.transparent, 
            
            // Apply the grey blocks to the background
            specialRegions: greyBlocks,

            // Using the TaskDataSource from day_view.dart
            dataSource: TaskDataSource(
              tasks.where((t) => !t.isAllDay && t.type != TaskType.birthday && t.startTime != null).toList(),
              context,
            ),
            
            // Aligns the task perfectly within its day column
            appointmentBuilder: (context, details) {
              final Appointment appointment = details.appointments.first;
              return Container(
                width: details.bounds.width,
                height: details.bounds.height,
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                child: AppointmentCard(appointment: appointment),
              );
            },
            
            onViewChanged: onViewChanged,
            onTap: (CalendarTapDetails details) {
              if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
                final tappedTask = tasks.firstWhere((t) => t.id == details.appointments!.first.id);
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

  Widget _buildDayTaskList(List<Task> dayTasks, bool isDark, Function(Task) onTaskTap) {
    if (dayTasks.isEmpty) return const SizedBox(height: 50);

    final bool isCollapsed = dayTasks.length > 2;
    final List<Task> displayedTasks = isCollapsed ? dayTasks.take(2).toList() : dayTasks;

    return Column(
      children: [
        ...displayedTasks.map((task) {
          final paletteMatch = appEventColors.firstWhere(
            (c) => c.light.value == task.colorValue || c.dark.value == task.colorValue,
            orElse: () => appEventColors[0],
          );
          final Color taskColor = isDark ? paletteMatch.dark : paletteMatch.light;
          final bool isCompleted = task.status == TaskStatus.completed;

          return GestureDetector(
            onTap: () => onTaskTap(task),
            child: Container(
              height: 20,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isCompleted ? taskColor.withOpacity(0.5) : taskColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
        if (isCollapsed)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              "+${dayTasks.length - 2}",
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}