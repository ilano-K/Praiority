// File: lib/features/calendar/presentation/widgets/calendars/week_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/appointment_card.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/task_summary_view.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/color_selector.dart';
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
          enablePointerInteraction: false,
          // CRITICAL: This makes the blocks repeat every day forever
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
              final firstDayOfWeek = date.subtract(Duration(days: date.weekday % 7));
              
              return _buildHeaderRow(context, colorScheme, firstDayOfWeek, isDark, now);
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
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0.5),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(isDark ? 0.05 : 0.08),
                  borderRadius: BorderRadius.circular(8), 
                ),
              );
            },

            // Uses cached DataSource
            dataSource: _dataSource,
            
            appointmentBuilder: (context, details) {
              final Appointment appointment = details.appointments.first;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: AppointmentCard(appointment: appointment),
              );
            },

            onViewChanged: widget.onViewChanged,
            
            onTap: (details) {
              if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
                final tappedTask = widget.tasks.firstWhere((t) => t.id == details.appointments!.first.id);
                widget.onTaskTap(tappedTask);
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

  // Extracted Header Builder used inside the Notifier
  Widget _buildHeaderRow(BuildContext context, ColorScheme colorScheme, DateTime firstDayOfWeek, bool isDark, DateTime now) {
    final List<DateTime> weekDays = List.generate(7, (i) => firstDayOfWeek.add(Duration(days: i)));

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
                      color: isToday ? colorScheme.onPrimary : colorScheme.onSurface, 
                      fontWeight: FontWeight.bold
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
    final dayAllDayTasks = widget.tasks.where((t) => 
      (t.isAllDay || t.type == TaskType.birthday) && 
      t.startTime != null && 
      DateUtils.isSameDay(t.startTime!, day)
    ).toList();

    if (dayAllDayTasks.isEmpty) return const SizedBox.shrink();
    final bool hasMore = dayAllDayTasks.length > 2;
    final displayTasks = dayAllDayTasks.take(2).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...displayTasks.map((task) {
          final paletteMatch = appEventColors.firstWhere(
            (c) => c.light.value == task.colorValue || c.dark.value == task.colorValue,
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