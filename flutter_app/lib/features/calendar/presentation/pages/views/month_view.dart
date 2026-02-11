// File: lib/features/calendar/presentation/widgets/calendars/month_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/utils/task_utils.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/calendar_builder.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/task_summary_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'day_view.dart'; // For TaskDataSource

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
          child: Center(
            child: Container(
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
                      : (isCurrentMonth
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withOpacity(0.2)),
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
          final range = date.range(CalendarScope.day);
          final dayTasks = widget.tasks
              .where(
                (t) =>
                    t.startTime != null &&
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
