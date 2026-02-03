// File: lib/features/calendar/presentation/pages/main_calendar.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/month_view.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/week_view.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/sheets/add_birthday_sheet.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/sheets/add_event_sheet.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/app_sidebar.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/calendar_builder.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/day_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/sheets/add_task_sheet.dart'; 
import '../../domain/entities/task.dart';
import '../widgets/components/calendar_ai_tip.dart'; 
import '../widgets/dialogs/app_confirmation_dialog.dart';
import '../widgets/dialogs/app_warning_dialog.dart';


class MainCalendar extends ConsumerStatefulWidget {
  const MainCalendar({super.key});

  @override
  ConsumerState<MainCalendar> createState() => _MainCalendarState();
}

class _MainCalendarState extends ConsumerState<MainCalendar> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = dateOnly(DateTime.now());
  DateTime? _lastRangeDate;
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
      ref.read(calendarControllerProvider.notifier).setRange(
        DateRange(scope: CalendarScope.day, startTime: _selectedDate),
      );
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _toggleFab() => _fabController.isDismissed ? _fabController.forward() : _fabController.reverse();

  // Logic for UI interactions (AI Tip, Error Dialogs, Sheets) stays here...
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
            
            onEdit: () {
              Navigator.pop(context); 
              _openTaskSheet(task);   
            },

            onDelete: () {
              showDialog(
                context: context,
                builder: (context) => AppConfirmationDialog(
                  title: "Delete Task",
                  message: "Are you sure you want to delete '${task.title}'? This action cannot be undone.",
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
              final newStatus = task.status == TaskStatus.completed 
                  ? TaskStatus.scheduled 
                  : TaskStatus.completed;
              
              final updatedTask = task.copyWith(status: newStatus);
              try {
                await controller.addTask(updatedTask);
                if (mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                _showErrorWarning(context, "Error", "An unexpected error occurred: $e");
              }
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
      if (task.type == TaskType.event) {
        return AddEventSheet(task: task);
      } else if (task.type == TaskType.birthday) {
        return AddBirthdaySheet(task: task);
      } else {
        // UPDATED: Pass the current calendar date as a fallback
        return AddTaskSheet(task: task, initialDate: _selectedDate);
      }
    },
  );
}

  void _showErrorWarning(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AppWarningDialog(
        title: title,
        message: message,
      ),
    );
  }

void _handleViewChanged(ViewChangedDetails details) {
  if (details.visibleDates.isEmpty) return;
  
  // Use the middle or first date of the visible range to avoid jumpiness
  final newDate = dateOnly(details.visibleDates[details.visibleDates.length ~/ 2]);
  
  if (_lastRangeDate == newDate) return;

  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 100), () {
    if (!mounted) return;
    
    _lastRangeDate = newDate;
    setState(() => _selectedDate = newDate);

    // --- THE FIX ---
    // Instead of guessing the scope, check the actual visible range length
    final scope = details.visibleDates.length > 1 
        ? CalendarScope.week 
        : CalendarScope.day;

    // For week view, set startTime to the first visible date and endTime to the last
    // For day view, endTime can be null or the same as startTime
    final startTime = details.visibleDates.first;
    final endTime = scope == CalendarScope.week ? details.visibleDates.last : null;

    ref.read(calendarControllerProvider.notifier).setRange(
      DateRange(
        scope: scope, 
        startTime: startTime,
        endTime: endTime,  // Add this to DateRange if it doesn't exist
      ),
    );
  });
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
    final isLoading = tasksAsync.isLoading;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: false,
      // --- PASS CALLBACK TO SIDEBAR ---
      drawer: AppSidebar(
      currentView: _currentView, // ADD THIS: Pass the current view state
      onViewSelected: (view) {
        setState(() {
          _currentView = view;
          // 1. FORCE THE CONTROLLER TO UPDATE
          _calendarController.view = view; 
        }); 
      },
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
              // UPDATED: Pass _selectedDate so the sheet knows which day you scrolled to
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
            if (isLoading) const LinearProgressIndicator(minHeight: 2) else const SizedBox(height: 2),

            Expanded(
              child: _buildCalendarView(tasks,colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER TO SWAP VIEWS ---
  Widget _buildCalendarView(List<Task>tasks , ColorScheme colorScheme) {
    final greyBlocks = _getGreyBlocks(colorScheme.secondary);
    
    if (_currentView == CalendarView.week) {
      // final day = DateRange(scope: CalendarScope.week, startTime: DateTime.now());
      // controller.setRange(day);
      return WeekView(
        tasks: tasks,
        calendarController: _calendarController,
        selectedDate: _selectedDate, 
        onViewChanged: _handleViewChanged,
        onTaskTap: _showAiTipBeforeEdit,
        // onDateTap: () => _pickDate(context),
        // greyBlocks: greyBlocks,
      );
   } else if (_currentView == CalendarView.month) {
      return MonthView(
        tasks: tasks,
        calendarController: _calendarController,
        selectedDate: _selectedDate, 
        onViewChanged: _handleViewChanged,
        onTaskTap: _showAiTipBeforeEdit,
        // onDateTap: () => _pickDate(context),
        // greyBlocks: greyBlocks,
      );
  }
    // Default to DayView
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