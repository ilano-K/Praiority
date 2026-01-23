// File: lib/features/calendar/presentation/pages/main_calendar.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_notifier.dart';
import 'package:flutter_app/features/calendar/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_app/features/calendar/domain/usecases/save_task_usecase.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/sheets/add_birthday_sheet.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/sheets/add_event_sheet.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/app_sidebar.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/calendar_builder.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/day_view.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/week_view.dart';
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
                    await deleteTask(ref, task.id);
                    if (mounted) Navigator.pop(context);
                  },
                ),
              );
            },

            onComplete: () async {
              final newStatus = task.status == TaskStatus.completed 
                  ? TaskStatus.scheduled 
                  : TaskStatus.completed;
              
              final updatedTask = task.copyWith(status: newStatus);
              try {
                await saveTask(ref, updatedTask);
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
          return AddTaskSheet(task: task);
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
  
  final newDate = dateOnly(details.visibleDates.first);
  if (_lastRangeDate == newDate) return;

  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 100), () {
    if (!mounted) return;
    
    _lastRangeDate = newDate;
    setState(() => _selectedDate = newDate);

    // Update the scope based on the CURRENT VIEW
    final currentScope = _currentView == CalendarView.week 
        ? CalendarScope.week 
        : CalendarScope.day;

    ref.read(calendarControllerProvider.notifier).setRange(
      DateRange(scope: currentScope, startTime: newDate),
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
        endTime: anchorDate.copyWith(hour: i, minute: 52), 
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
      // --- PASS CALLBACK TO SIDEBAR ---
      drawer: AppSidebar(
        onViewSelected: (view) => setState(() => _currentView = view),
      ),
      floatingActionButton: CalendarBuilder.buildMainFab(
        colorScheme: colorScheme,
        fabController: _fabController,
        fabAnimation: _fabAnimation,
        onToggle: _toggleFab,
        onOptionTap: (label) {
          _toggleFab();
          if (label == "Task") {
             showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const AddTaskSheet());
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
              child: _buildCalendarView(tasks, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER TO SWAP VIEWS ---
  Widget _buildCalendarView(List<Task> tasks, ColorScheme colorScheme) {
    if (_currentView == CalendarView.week) {
    return WeekView(
      tasks: tasks,
      calendarController: _calendarController,
      // Pass the selectedDate so WeekView knows which week to display in the header
      selectedDate: _selectedDate, 
      onViewChanged: _handleViewChanged,
      onTaskTap: _showAiTipBeforeEdit,
      // Pass the date picker logic to allow header interaction
      onDateTap: () => _pickDate(context), 
      greyBlocks: _getGreyBlocks(colorScheme.secondary),
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
      greyBlocks: _getGreyBlocks(colorScheme.secondary),
    );
  }
}