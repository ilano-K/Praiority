// File: lib/features/calendar/presentation/pages/main_calendar.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';

import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';

import 'package:flutter_app/features/calendar/presentation/widgets/calendars/month_view.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/week_view.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/day_view.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/calendar_builder.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/app_sidebar.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/calendar_ai_tip.dart'; 
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';

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
  
  // FIX: ValueNotifier allows us to update the header WITHOUT rebuilding the calendar
  late final ValueNotifier<DateTime> _uiDateNotifier;

  DateTime? _lastFetchDate; 
  Timer? _debounceTimer;
  
  CalendarView _currentView = CalendarView.day;

  final CalendarController _calendarController = CalendarController();
  late AnimationController _fabController;
  late Animation<double> _fabAnimation; 

  List<TimeRegion>? _cachedGreyBlocks;
  Brightness? _lastBrightness;

  @override
  void initState() {
    super.initState();
    // Initialize notifier
    _uiDateNotifier = ValueNotifier(_selectedDate);

    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _fabAnimation = CurvedAnimation(parent: _fabController, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialRange = _selectedDate.buffered(CalendarScope.day);
      ref.read(calendarControllerProvider.notifier).setRange(initialRange);
      _lastFetchDate = _selectedDate;

      ref.read(tagsProvider);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    
    if (_cachedGreyBlocks == null || _lastBrightness != brightness) {
      _lastBrightness = brightness;
      final color = Theme.of(context).colorScheme.secondary;
      _cachedGreyBlocks = _generateGreyBlocks(color);
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    _uiDateNotifier.dispose(); // Clean up notifier
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _toggleFab() => _fabController.isDismissed ? _fabController.forward() : _fabController.reverse();

  // --- OPTIMIZED VIEW HANDLER ---
  void _handleViewChanged(ViewChangedDetails details) {
    if (details.visibleDates.isEmpty) return;

    CalendarScope scope;
    if (details.visibleDates.length <= 1) {
      scope = CalendarScope.day;
    } else if (details.visibleDates.length <= 7) {
      scope = CalendarScope.week;
    } else {
      scope = CalendarScope.month;
    }

    DateTime anchorDate;
    if (scope == CalendarScope.month) {
      int midIndex = details.visibleDates.length ~/ 2;
      anchorDate = dateOnly(details.visibleDates[midIndex]);
    } else {
      anchorDate = dateOnly(details.visibleDates.first);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_selectedDate != anchorDate) {
        // DEBUG: Confirming we are NOT rebuilding
        print("DEBUG: Scroll detected -> Updating Notifier to $anchorDate (NO REBUILD)");
        
        // CRITICAL FIX: Update Notifier only. DO NOT call setState().
        _selectedDate = anchorDate; 
        _uiDateNotifier.value = anchorDate; 
      }

      bool shouldFetch = false;
      if (_lastFetchDate == null) {
        shouldFetch = true;
      } else {
        final daysDiff = anchorDate.difference(_lastFetchDate!).inDays.abs();
        if (scope == CalendarScope.day && daysDiff > 15) shouldFetch = true; 
        if (scope == CalendarScope.week && daysDiff > 80) shouldFetch = true; 
        if (scope == CalendarScope.month && daysDiff > 180) shouldFetch = true; 
      }

      if (shouldFetch) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          print("DEBUG: Fetching new data from database...");
          _lastFetchDate = anchorDate;
          final range = anchorDate.buffered(scope);
          print(range);
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

    final newRange = _selectedDate.buffered(scope);
    ref.read(calendarControllerProvider.notifier).setRange(newRange);
    _lastFetchDate = _selectedDate;
  }

  // --- UI HELPERS ---
  void _showAiTipBeforeEdit(Task task) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: AiTipWidget(
            title: task.title.isEmpty ? "New Task" : task.title,
            taskId: task.id,
            description: task.description ?? "No description provided.",
            generatedTip: task.aiTip ?? "", 
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
      // Manual pick MUST use setState to jump correctly
      setState(() {
        _selectedDate = picked;
        _uiDateNotifier.value = picked;
        _calendarController.displayDate = picked;
      });
    }
  }

  List<TimeRegion> _generateGreyBlocks(Color color) {
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
    // DEBUG: THIS SHOULD ONLY PRINT ONCE OR WHEN VIEW CHANGES
    print("DEBUG: MainCalendar build() - FULL REBUILD (If this spams, it's bad)");

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
            final now = DateTime.now();
            final dateWithCurrentTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              now.hour,
              now.minute,
            );
            showModalBottomSheet(
              context: context, 
              isScrollControlled: true, 
              backgroundColor: Colors.transparent, 
              builder: (context) => AddTaskSheet(initialDate: dateWithCurrentTime),
            );
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // FIX: Wrap AppBar in ValueListenableBuilder
            // Only this tiny part rebuilds when you swipe!
            ValueListenableBuilder<DateTime>(
              valueListenable: _uiDateNotifier,
              builder: (context, date, _) {
                return CalendarBuilder.buildAppBar(
                  context: context,
                  colorScheme: colorScheme,
                  selectedDate: date,
                  onPickDate: () => _pickDate(context),
                );
              },
            ),
            const SizedBox(height: 2),
            Expanded(
              child: RepaintBoundary(
                  child: CalendarViewSwitcher(
                  currentView: _currentView,
                  tasks: tasks,
                  calendarController: _calendarController,
                  selectedDate: _selectedDate,
                  
                  // PASS NOTIFIER DOWN
                  // Note: Your DayView needs to accept 'dateNotifier' 
                  // as shown in the previous solution to update the sidebar!
                  dateNotifier: _uiDateNotifier, 
                  
                  onViewChanged: _handleViewChanged,
                  onTaskTap: _showAiTipBeforeEdit,
                  onDateTap: () => _pickDate(context),
                  greyBlocks: _cachedGreyBlocks ?? [],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarViewSwitcher extends StatelessWidget {
  final CalendarView currentView;
  final List<Task> tasks;
  final CalendarController calendarController;
  final DateTime selectedDate;
  
  // Accept the notifier
  final ValueNotifier<DateTime> dateNotifier;
  
  final Function(ViewChangedDetails) onViewChanged;
  final Function(Task) onTaskTap;
  final VoidCallback? onDateTap; 
  final List<TimeRegion> greyBlocks;

  const CalendarViewSwitcher({
    super.key,
    required this.currentView,
    required this.tasks,
    required this.calendarController,
    required this.selectedDate,
    required this.dateNotifier, // Added
    required this.onViewChanged,
    required this.onTaskTap,
    this.onDateTap,
    required this.greyBlocks,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentView) {
      case CalendarView.week:
        return WeekView(
          tasks: tasks,
          calendarController: calendarController,
          selectedDate: selectedDate,
          onViewChanged: onViewChanged,
          dateNotifier: dateNotifier,
          onTaskTap: onTaskTap,
        );
      
      case CalendarView.month:
        return MonthView(
          tasks: tasks,
          calendarController: calendarController,
          selectedDate: selectedDate,
          onViewChanged: onViewChanged,
          dateNotifier: dateNotifier,
          onTaskTap: onTaskTap,
        );
      
      case CalendarView.day:
      default:
        // Ensure DayView accepts dateNotifier as defined in previous step
        return DayView(
          tasks: tasks,
          calendarController: calendarController,
          selectedDate: selectedDate,
          dateNotifier: dateNotifier, 
          onViewChanged: onViewChanged,
          onTaskTap: onTaskTap,
          onDateTap: onDateTap!,
          greyBlocks: greyBlocks,
        );
    }
  }
}