// File: lib/features/calendar/presentation/widgets/calendars/week_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/calendar_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/appointment_card.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/task_summary_view.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/color_selector.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/sheets/add_task_sheet.dart';
// Import DayView to share the TaskDataSource logic
import 'day_view.dart';

class WeekView extends ConsumerStatefulWidget {
  final List<Task> tasks;
  final CalendarController calendarController;
  final DateTime selectedDate;

  // FIX: Accept Notifier from MainCalendar
  final ValueNotifier<DateTime> dateNotifier;

  final Function(ViewChangedDetails) onViewChanged;
  final Function(Task) onTaskTap;

  const WeekView({
    super.key,
    required this.tasks,
    required this.calendarController,
    required this.selectedDate,
    required this.dateNotifier, // Add to constructor
    required this.onViewChanged,
    required this.onTaskTap,
  });

  @override
  ConsumerState<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends ConsumerState<WeekView> {
  late TaskDataSource _dataSource;
  late List<TimeRegion> _gridRegions; // Cache the grid
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isInitialized) {
      // 1. Initialize DataSource ONCE
      _dataSource = TaskDataSource(widget.tasks, isDark);

      // 2. Generate Infinite Grid ONCE
      // We generate 24 blocks for one day and set them to repeat DAILY.
      // This ensures the grey background exists for all eternity without rebuilding.
      _gridRegions = _generateInfiniteGrid();

      _isInitialized = true;
    } else {
      _dataSource.updateData(widget.tasks, isDark);
    }
  }

  @override
  void didUpdateWidget(WeekView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update data if tasks change
    if (oldWidget.tasks != widget.tasks) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      if (_isInitialized) {
        _dataSource.updateData(widget.tasks, isDark);
      }
    }
  }

  // Optimized Infinite Grid Generator
  List<TimeRegion> _generateInfiniteGrid() {
    final List<TimeRegion> regions = [];
    // Anchor date (e.g., Jan 1, 2020) - exact date doesn't matter for recurrence
    final DateTime anchor = DateTime(2020, 1, 1, 0, 0);

    for (int h = 0; h < 24; h++) {
      regions.add(
        TimeRegion(
          startTime: DateTime(anchor.year, anchor.month, anchor.day, h, 0),
          endTime: DateTime(anchor.year, anchor.month, anchor.day, h, 59),
          enablePointerInteraction: true,
          // CRITICAL: enablePointerInteraction: true allows taps to be registered by the calendar
          // The IgnorePointer wrapper on the visual element prevents the Container from blocking taps
          recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
        ),
      );
    }
    return regions;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime now = DateTime.now();

    if (!_isInitialized) return const SizedBox();

    return Column(
      children: [
        // --- HEADER (Updates via Notifier) ---
        Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: ValueListenableBuilder<DateTime>(
            valueListenable: widget.dateNotifier,
            builder: (context, date, _) {
              // Calculate the week start based on the swipe date
              final firstDayOfWeek = date.subtract(
                Duration(days: date.weekday % 7),
              );

              return _buildHeaderRow(
                context,
                colorScheme,
                firstDayOfWeek,
                isDark,
                now,
              );
            },
          ),
        ),

        // --- CALENDAR BODY (Stable) ---
        Expanded(
          child: SfCalendar(
            view: CalendarView.week,
            controller: widget.calendarController,
            headerHeight: 0,
            viewHeaderHeight: 0,
            backgroundColor: colorScheme.surface,
            cellBorderColor: Colors.transparent,

            // Uses cached infinite grid
            specialRegions: _gridRegions,

            // --- GRID LOOK ---
            timeRegionBuilder: (context, details) {
              return IgnorePointer(
                ignoring: true,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 1,
                    vertical: 0.5,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(
                      isDark ? 0.05 : 0.08,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },

            // Uses cached DataSource
            dataSource: _dataSource,

            appointmentBuilder: (context, details) {
              final Appointment appointment = details.appointments.first;
              
              // Find the actual Task object from widget.tasks
              final task = widget.tasks.firstWhere(
                (t) => t.id == appointment.id,
                orElse: () => Task(
                  id: "temp",
                  title: "Missing",
                  startTime: DateTime.now(),
                ),
              );
              
              if (task.id == "temp") {
                return Container(color: Colors.red, width: 20, height: 20);
              }
              
              final bool isCompleted = task.status == TaskStatus.completed;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
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
                child: Padding(
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
                              color: isCompleted 
                                  ? colorScheme.onSurface.withOpacity(0.5) 
                                  : colorScheme.onSurface.withOpacity(0.7),
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
              );
            },

            onViewChanged: widget.onViewChanged,

            onTap: (details) {
              if (details.targetElement == CalendarElement.appointment &&
                  details.appointments != null) {
                final tappedTask = widget.tasks.firstWhere(
                  (t) => t.id == details.appointments!.first.id,
                );
                widget.onTaskTap(tappedTask);
              } else if (details.targetElement == CalendarElement.calendarCell &&
                  details.date != null) {
                _handleEmptySlotTap(context, details.date!);
              }
            },

            timeSlotViewSettings: TimeSlotViewSettings(
              timeRulerSize: 60,
              timeTextStyle: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              timeIntervalHeight: 85,
            ),
          ),
        ),
      ],
    );
  }

  /// Check if a specific time slot is empty (no existing task)
  /// Extracts the hour from dateTime and checks that specific hour block
  bool _isSlotEmpty(DateTime dateTime) {
    // Extract hour from the tapped time
    final hour = dateTime.hour;
    final slotStart = DateTime(dateTime.year, dateTime.month, dateTime.day, hour, 0);
    final slotEnd = DateTime(dateTime.year, dateTime.month, dateTime.day, hour, 59, 59);

    return !widget.tasks.any((task) {
      if (task.startTime == null) return false;
      final taskStart = task.startTime!;
      final taskEnd = task.endTime ?? taskStart.add(const Duration(hours: 1));

      // Check if task overlaps with this hour slot
      return taskStart.isBefore(slotEnd) && taskEnd.isAfter(slotStart);
    });
  }

  /// Handle empty slot tap - open AddTaskSheet if slot is empty
  /// Normalizes time to start of hour for accurate task scheduling
  void _handleEmptySlotTap(BuildContext context, DateTime tappedTime) {
    if (_isSlotEmpty(tappedTime)) {
      // Normalize to the exact start of the clicked hour
      final normalizedTime = DateTime(
        tappedTime.year,
        tappedTime.month,
        tappedTime.day,
        tappedTime.hour,
        0,
        0,
      );
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddTaskSheet(initialDate: normalizedTime),
      );
    }
  }

  // Extracted Header Builder used inside the Notifier
  Widget _buildHeaderRow(
    BuildContext context,
    ColorScheme colorScheme,
    DateTime firstDayOfWeek,
    bool isDark,
    DateTime now,
  ) {
    final List<DateTime> weekDays = List.generate(
      7,
      (i) => firstDayOfWeek.add(Duration(days: i)),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 60),
        ...weekDays.map((day) {
          final bool isToday = DateUtils.isSameDay(day, now);

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(day),
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isToday ? colorScheme.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    DateFormat('d').format(day),
                    style: TextStyle(
                      fontSize: 14,
                      color: isToday
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Tiny task dots or summary for the week header
                SizedBox(
                  height: 80,
                  child: _buildDayTaskList(context, day, isDark),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDayTaskList(BuildContext context, DateTime day, bool isDark) {
    final dayAllDayTasks = widget.tasks
        .where(
          (t) =>
              (t.isAllDay || t.type == TaskType.birthday) &&
              t.startTime != null &&
              DateUtils.isSameDay(t.startTime!, day),
        )
        .toList();

    if (dayAllDayTasks.isEmpty) return const SizedBox.shrink();
    final bool hasMore = dayAllDayTasks.length > 2;
    final displayTasks = dayAllDayTasks.take(2).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayTasks.map((task) {
          final paletteMatch = appEventColors.firstWhere(
            (c) =>
                c.light.value == task.colorValue ||
                c.dark.value == task.colorValue,
            orElse: () => appEventColors[0],
          );
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => widget.onTaskTap(task),
                child: Container(
                  height: 22,
                  width: 38,
                  decoration: BoxDecoration(
                    color: isDark ? paletteMatch.dark : paletteMatch.light,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          );
        }),
        if (hasMore)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => TaskSummaryView(
                    date: day,
                    tasks: dayAllDayTasks,
                    onTaskTap: widget.onTaskTap,
                  ),
                );
              },
              child: Container(
                height: 22,
                width: 38,
                alignment: Alignment.center,
                child: Text(
                  "+${dayAllDayTasks.length - 2}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
