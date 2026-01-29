// File: lib/features/calendar/presentation/pages/week_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/appointment_card.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/task_summary_view.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/color_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'day_view.dart'; 

class WeekView extends ConsumerWidget {
  final List<Task> tasks;
  final CalendarController calendarController;
  final DateTime selectedDate;
  final Function(ViewChangedDetails) onViewChanged;
  final Function(Task) onTaskTap;

  const WeekView({
    super.key,
    required this.tasks,
    required this.calendarController,
    required this.selectedDate,
    required this.onViewChanged,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime now = DateTime.now();

    final DateTime firstDayOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday % 7));

    // --- GRID GENERATION ---
    final List<TimeRegion> gridRegions = [];
    for (int d = 0; d < 7; d++) {
      final day = firstDayOfWeek.add(Duration(days: d));
      for (int h = 0; h < 24; h++) {
        gridRegions.add(
          TimeRegion(
            startTime: DateTime(day.year, day.month, day.day, h, 0),
            endTime: DateTime(day.year, day.month, day.day, h, 59),
            enablePointerInteraction: false,
          ),
        );
      }
    }

    return Column(
      children: [
        _buildHeader(context, colorScheme, firstDayOfWeek, isDark, now),
        Expanded(
          child: SfCalendar(
            view: CalendarView.week,
            controller: calendarController,
            headerHeight: 0,
            viewHeaderHeight: 0, 
            backgroundColor: colorScheme.surface,
            cellBorderColor: Colors.transparent, 
            specialRegions: gridRegions,
            
            // --- GRID LOOK: 1px Gaps & Shorter Blocks ---
            timeRegionBuilder: (context, details) {
              return Container(
                // 0.5 vertical margin creates a total 1px line between hours
                margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.5),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(isDark ? 0.05 : 0.08),
                  borderRadius: BorderRadius.circular(8), 
                ),
              );
            },

            dataSource: TaskDataSource(
              tasks.where((t) => !t.isAllDay && t.type != TaskType.birthday && t.startTime != null).toList(),
              context,
            ),
            
            appointmentBuilder: (context, details) {
              final Appointment appointment = details.appointments.first;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: AppointmentCard(appointment: appointment),
              );
            },

            onViewChanged: onViewChanged,
            onTap: (details) {
              if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
                final tappedTask = tasks.firstWhere((t) => t.id == details.appointments!.first.id);
                onTaskTap(tappedTask);
              }
            },
            
            timeSlotViewSettings: TimeSlotViewSettings(
              timeRulerSize: 60,
              timeTextStyle: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              // SHORTER BLOCKS: Reduced to 85 for a compact grid
              timeIntervalHeight: 85, 
            ),
          ),
        ),
      ],
    );
  }

Widget _buildHeader(BuildContext context, ColorScheme colorScheme, DateTime firstDayOfWeek, bool isDark, DateTime now) {
    final List<DateTime> weekDays = List.generate(7, (i) => firstDayOfWeek.add(Duration(days: i)));
    return Container(
      color: colorScheme.surface,
      // REDUCED: bottom padding from 12 to 8 to save space
      padding: const EdgeInsets.only(bottom: 8, top: 8), 
      child: Row(
        children: [
          const SizedBox(width: 60),
          ...weekDays.map((day) {
            final bool isToday = DateUtils.isSameDay(day, now);
            return Expanded(
              child: Column(
                // ADDED: MainAxisSize.min to ensure the column doesn't try to take extra space
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(DateFormat('E').format(day), style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 4), // Reduced from 6 to 4
                  Container(
                    padding: const EdgeInsets.all(6), // Reduced from 8 to 6
                    decoration: BoxDecoration(
                      color: isToday ? colorScheme.primary : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      DateFormat('d').format(day),
                      style: TextStyle(
                        fontSize: 14, // Slightly reduced from 15 to 14
                        color: isToday ? colorScheme.onPrimary : colorScheme.onSurface, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  _buildDayTaskList(context, day, isDark),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayTaskList(BuildContext context, DateTime day, bool isDark) {
    final dayAllDayTasks = tasks.where((t) => 
      (t.isAllDay || t.type == TaskType.birthday) && 
      t.startTime != null && 
      DateUtils.isSameDay(t.startTime!, day)
    ).toList();

    final bool hasMore = dayAllDayTasks.length > 2;
    final displayTasks = dayAllDayTasks.take(2).toList();

    return ConstrainedBox(
      // FIXED: Changed from fixed height 44 to a maximum constraint
      constraints: const BoxConstraints(minHeight: 40, maxHeight: 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...displayTasks.map((task) {
            final paletteMatch = appEventColors.firstWhere(
              (c) => c.light.value == task.colorValue || c.dark.value == task.colorValue,
              orElse: () => appEventColors[0],
            );
            return GestureDetector(
              onTap: () => onTaskTap(task),
              child: Container(
                height: 12, // Reduced from 14 to 12 to prevent overflow
                width: 30, 
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: isDark ? paletteMatch.dark : paletteMatch.light,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
          if (hasMore)
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => TaskSummaryView(
                    date: day,
                    tasks: dayAllDayTasks,
                    onTaskTap: onTaskTap,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 1), // Reduced from 2 to 1
                child: Text("+${dayAllDayTasks.length - 2}", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}