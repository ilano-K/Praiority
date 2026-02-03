// File: lib/features/calendar/presentation/pages/main_calendar.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// --- DOMAIN IMPORTS ---
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';

// --- MANAGER IMPORTS ---
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';

// --- WIDGET IMPORTS ---
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/month_view.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/week_view.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/day_view.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/calendar_builder.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/app_sidebar.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/calendar_ai_tip.dart'; 
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';

// --- SHEET/DIALOG IMPORTS ---
import 'package:flutter_app/features/calendar/presentation/widgets/sheets/add_birthday_sheet.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/sheets/add_event_sheet.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/sheets/add_task_sheet.dart'; 
import 'package:flutter_app/features/calendar/presentation/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/dialogs/app_warning_dialog.dart';


class MainCalendar extends ConsumerStatefulWidget {
  const MainCalendar({super.key});

  @override
  ConsumerState<MainCalendar> createState() => _MainCalendarState();
}

class _MainCalendarState extends ConsumerState<MainCalendar> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = dateOnly(DateTime.now());
  DateTime? _lastFetchDate; // Tracks when we last fetched data
  Timer? _debounceTimer;
  
  // --- VIEW STATE ---
  CalendarView _currentView = CalendarView.day;

  final CalendarController _calendarController = CalendarController();
  late AnimationController _fabController;
  late Animation<double> _fabAnimation; 

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _fabAnimation = CurvedAnimation(parent: _fabController, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialRange = _selectedDate.buffered(CalendarScope.day);
      ref.read(calendarControllerProvider.notifier).setRange(initialRange);
      _lastFetchDate = _selectedDate;
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _toggleFab() => _fabController.isDismissed ? _fabController.forward() : _fabController.reverse();

  // --- OPTIMIZED VIEW CHANGE HANDLER ---
  void _handleViewChanged(ViewChangedDetails details) {
    if (details.visibleDates.isEmpty) return;

    // 1. Determine Scope
    CalendarScope scope;
    if (details.visibleDates.length <= 1) {
      scope = CalendarScope.day;
    } else if (details.visibleDates.length <= 7) {
      scope = CalendarScope.week;
    } else {
      scope = CalendarScope.month;
    }

    // 2. Determine "Anchor Date"
    DateTime anchorDate;
    if (scope == CalendarScope.month) {
      int midIndex = details.visibleDates.length ~/ 2;
      anchorDate = dateOnly(details.visibleDates[midIndex]);
    } else {
      anchorDate = dateOnly(details.visibleDates.first);
    }

    // 3. Post-Frame Callback to avoid "setState during build" errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Update the AppBar Date Title immediately (Cheap)
      if (_selectedDate != anchorDate) {
        setState(() => _selectedDate = anchorDate);
      }

      // 4. SMART FETCHING LOGIC
      // Only fetch new data if we have scrolled significantly away from the last fetch point.
      // Since we buffer 30 days, we don't need to fetch if we only moved 1 day.
      // Let's refetch if we moved more than 50% of our buffer.
      
      bool shouldFetch = false;
      if (_lastFetchDate == null) {
        shouldFetch = true;
      } else {
        final daysDiff = anchorDate.difference(_lastFetchDate!).inDays.abs();
        if (scope == CalendarScope.day && daysDiff > 15) shouldFetch = true; // Moved 15 days
        if (scope == CalendarScope.week && daysDiff > 21) shouldFetch = true; // Moved 3 weeks
        if (scope == CalendarScope.month && daysDiff > 30) shouldFetch = true; // Moved 1 month
      }

      if (shouldFetch) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          _lastFetchDate = anchorDate;
          final range = anchorDate.buffered(scope);
          ref.read(calendarControllerProvider.notifier).setRange(range);
        });
      }
    });
  }

  void _onViewSwitched(CalendarView view) {
    setState(() {
      _currentView = view;
      _calendarController.view = view; 
    });

    CalendarScope scope;
    if (view == CalendarView.day) {
      scope = CalendarScope.day;
    } else if (view == CalendarView.week || view == CalendarView.workWeek) {
      scope = CalendarScope.week;
    } else {
      scope = CalendarScope.month;
    }

    // Force fetch on view switch
    final newRange = _selectedDate.buffered(scope);
    ref.read(calendarControllerProvider.notifier).setRange(newRange);
    _lastFetchDate = _selectedDate;
  }

  // --- UI HELPERS (Kept same) ---
  void _showAiTipBeforeEdit(Task task) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: AiTipWidget(
            title: task.title.isEmpty ? "New Task" : task.title,
            description: task.description ?? "No description provided.",
            generatedTip: "Focus on completing this during your peak energy hours today.", 
            isCompleted: task.status == TaskStatus.completed,
            onEdit: () { Navigator.pop(context); _openTaskSheet(task); },
            onDelete: () {
              showDialog(
                context: context,
                builder: (context) => AppConfirmationDialog(
                  title: "Delete Task",
                  message: "Are you sure you want to delete '${task.title}'?",
                  confirmLabel: "Delete",
                  isDestructive: true,
                  onConfirm: () async {
                    final controller = ref.read(calendarControllerProvider.notifier);
                    await controller.deleteTask(task);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              );
            },
            onComplete: task.type == TaskType.birthday ? null : () async {
              final controller = ref.read(calendarControllerProvider.notifier);
              final newStatus = task.status == TaskStatus.completed ? TaskStatus.scheduled : TaskStatus.completed;
              final updatedTask = task.copyWith(status: newStatus);
              await controller.addTask(updatedTask);
              if (mounted) Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _openTaskSheet(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (task.type == TaskType.event) return AddEventSheet(task: task);
        if (task.type == TaskType.birthday) return AddBirthdaySheet(task: task);
        return AddTaskSheet(task: task, initialDate: _selectedDate);
      },
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await pickDate(context, initialDate: _selectedDate);
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calendarController.displayDate = picked;
      });
    }
  }

  List<TimeRegion> _getGreyBlocks(Color color) {
    List<TimeRegion> regions = [];
    final DateTime anchorDate = DateTime(2020, 1, 1);
    for (int i = 0; i < 24; i++) {
      regions.add(TimeRegion(
        startTime: anchorDate.copyWith(hour: i, minute: 0),
        endTime: anchorDate.copyWith(hour: i, minute: 59), 
        color: color, 
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
      ));
    }
    return regions;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tasksAsync = ref.watch(calendarControllerProvider);
    final tasks = tasksAsync.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: false,
      drawer: AppSidebar(
        currentView: _currentView, 
        onViewSelected: _onViewSwitched, 
      ),
      floatingActionButton: CalendarBuilder.buildMainFab(
        colorScheme: colorScheme,
        fabController: _fabController,
        fabAnimation: _fabAnimation,
        onToggle: _toggleFab,
        onOptionTap: (label) {
          _toggleFab();
          if (label == "Task") {
            showModalBottomSheet(
              context: context, 
              isScrollControlled: true, 
              backgroundColor: Colors.transparent, 
              builder: (context) => AddTaskSheet(initialDate: _selectedDate),
            );
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            CalendarBuilder.buildAppBar(
              context: context,
              colorScheme: colorScheme,
              selectedDate: _selectedDate,
              onPickDate: () => _pickDate(context),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: _buildCalendarView(tasks, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(List<Task> tasks, ColorScheme colorScheme) {
    final greyBlocks = _getGreyBlocks(colorScheme.secondary);
    
    if (_currentView == CalendarView.week) {
      return WeekView(
        tasks: tasks,
        calendarController: _calendarController,
        selectedDate: _selectedDate, 
        onViewChanged: _handleViewChanged,
        onTaskTap: _showAiTipBeforeEdit,
      );
    } else if (_currentView == CalendarView.month) {
      return MonthView(
        tasks: tasks,
        calendarController: _calendarController,
        selectedDate: _selectedDate, 
        onViewChanged: _handleViewChanged,
        onTaskTap: _showAiTipBeforeEdit,
      );
    }
    return DayView(
      tasks: tasks,
      calendarController: _calendarController,
      selectedDate: _selectedDate,
      onViewChanged: _handleViewChanged,
      onTaskTap: _showAiTipBeforeEdit,
      onDateTap: () => _pickDate(context),
      greyBlocks: greyBlocks,
    );
  }
}