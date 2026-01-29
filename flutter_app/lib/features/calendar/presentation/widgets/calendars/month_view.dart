// File: lib/features/calendar/presentation/widgets/calendars/month_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/task_summary_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'day_view.dart'; 

class MonthView extends ConsumerWidget {
  final List<Task> tasks;
  final CalendarController calendarController;
  final DateTime selectedDate;
  final Function(ViewChangedDetails) onViewChanged;
  final Function(Task) onTaskTap;

  const MonthView({
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

  return SfCalendar(
    view: CalendarView.month,
    controller: calendarController,
    headerHeight: 0,
    backgroundColor: colorScheme.surface,
    cellBorderColor: Colors.transparent,
    dataSource: TaskDataSource(tasks, context),
    
    // --- THE FIX ---
    // This allows the parent widget to update the Month name in the header
    onViewChanged: onViewChanged, 
    
    monthCellBuilder: (context, details) {
      final bool isToday = DateUtils.isSameDay(details.date, now);
      
      // Fixed logic: Check against the controller's display date to 
      // accurately dim dates from the previous or next month while scrolling.
      final bool isCurrentMonth = details.date.month == (calendarController.displayDate?.month ?? now.month);
      
      // Filter tasks for indicators
      final dayTasks = tasks.where((t) => 
        t.startTime != null && DateUtils.isSameDay(t.startTime!, details.date)
      ).toList();

      return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withOpacity(isDark ? 0.03 : 0.05),
          borderRadius: BorderRadius.circular(8),
          border: DateUtils.isSameDay(details.date, selectedDate)
              ? Border.all(color: colorScheme.primary.withOpacity(0.5), width: 1)
              : null,
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isToday ? colorScheme.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Text(
                details.date.day.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isToday 
                      ? colorScheme.onPrimary 
                      : (isCurrentMonth ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.2)),
                ),
              ),
            ),
            const Spacer(),
            if (dayTasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dayTasks.take(3).map((task) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(task.colorValue ?? colorScheme.primary.value).withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                  )).toList(),
                ),
              ),
          ],
        ),
      );
    },

      onTap: (details) {
        // Trigger Summary View for both cell and appointment taps
        if (details.targetElement == CalendarElement.calendarCell || 
            details.targetElement == CalendarElement.appointment) {
          
          final date = details.date!;
          final dayTasks = tasks.where((t) => 
            t.startTime != null && DateUtils.isSameDay(t.startTime!, date)
          ).toList();

          if (dayTasks.isNotEmpty) {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => TaskSummaryView(
                date: date,
                tasks: dayTasks,
                onTaskTap: onTaskTap,
              ),
            );
          }
        }
      },
    );
  }
}