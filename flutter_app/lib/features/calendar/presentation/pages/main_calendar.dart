// File: lib/features/calendar/presentation/pages/main_calendar.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/presentation/controllers/calendar_controller_providers.dart';
import 'package:flutter_app/features/calendar/presentation/services/delete_task_service.dart';
import 'package:flutter_app/features/calendar/presentation/services/save_task_service.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/add_birthday_sheet.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/add_event_sheet.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/color_selector.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/date_picker.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/dialogs/app_warning_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math; 
import 'dart:async';

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/add_task_sheet.dart'; 
import '../widgets/appointment_card.dart'; 
import '../../../../core/services/theme/theme_notifier.dart'; 
import '../../domain/entities/task.dart';
// --- IMPORT AI TIP WIDGET ---
import '../widgets/ai_tip_widget.dart'; 
import 'task_view.dart';
// --- IMPORT CONFLICT EXCEPTIONS ---
import 'package:flutter_app/core/errors/task_conflict_exception.dart';

class MainCalendar extends ConsumerStatefulWidget {
  const MainCalendar({super.key});

  @override
  ConsumerState<MainCalendar> createState() => _MainCalendarState();
}

class _MainCalendarState extends ConsumerState<MainCalendar> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = dateOnly(DateTime.now());
  DateTime? _lastRangeDate;
  Timer? _debounceTimer;

  final CalendarController _calendarController = CalendarController();
  late AnimationController _fabController;
  late Animation<double> _fabAnimation; 

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    
    _fabAnimation = CurvedAnimation(
      parent: _fabController, 
      curve: Curves.easeOut,
    );

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

  void _toggleFab() {
    _fabController.isDismissed ? _fabController.forward() : _fabController.reverse();
  }

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
            // Show confirmation before deleting
            showDialog(
              context: context,
              builder: (context) => AppConfirmationDialog(
                title: "Delete Task",
                message: "Are you sure you want to delete '${task.title}'? This action cannot be undone.",
                confirmLabel: "Delete",
                isDestructive: true, // This makes the button red
                onConfirm: () async {
                  await deleteTask(ref, task.id);
                  if (mounted) Navigator.pop(context); // Close the AI Tip widget
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
                // 1. Perform the async save
                await saveTask(ref, updatedTask);
                
                // 2. Close the dialog ONLY if the operation was successful 
                // and the user hasn't already navigated away.
                if (context.mounted) {
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
  
@override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tasksAsync = ref.watch(calendarControllerProvider);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // --- SEAMLESS DATA HANDLING ---
    // We grab whatever tasks are available, even if currently loading
    final tasks = tasksAsync.valueOrNull ?? [];
    final isLoading = tasksAsync.isLoading;
    final hasError = tasksAsync.hasError;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: _buildMainFab(colorScheme),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, colorScheme),

            // Subtle loading indicator at the top so the user knows a fetch is happening
            if (isLoading)
              const LinearProgressIndicator(minHeight: 2)
            else
              const SizedBox(height: 2),

            Expanded(
              child: hasError && tasks.isEmpty
                  ? Center(child: Text("Error: ${tasksAsync.error}"))
                  : Column(
                      children: [
                        // --- ALL DAY & SIDEBAR SECTION ---
                        Container(
                          color: colorScheme.surface,
                          width: double.infinity,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDateSidebar(colorScheme),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12, right: 12, bottom: 8),
                                  child: _buildAllDayList(tasks, isDark),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- MAIN CALENDAR SECTION ---
                        Expanded(
                          child: SfCalendar(
                            view: CalendarView.day,
                            controller: _calendarController,
                            headerHeight: 0,
                            viewHeaderHeight: 0,
                            backgroundColor: colorScheme.surface,
                            cellBorderColor: Colors.transparent,
                            // The dataSource updates seamlessly without rebuilding the widget
                            dataSource: _TaskDataSource(
                              tasks.where((t) => !t.isAllDay && t.type != TaskType.birthday && t.startTime != null).toList(), 
                              context
                            ),
                            appointmentBuilder: (context, details) {
                              return AppointmentCard(appointment: details.appointments.first);
                            },
                            specialRegions: _getGreyBlocks(colorScheme.secondary),
                            onViewChanged: _handleViewChanged,
                            onTap: (CalendarTapDetails details) {
                              if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
                                final Appointment selectedAppt = details.appointments!.first;
                                final tappedTask = tasks.firstWhere((t) => t.id == selectedAppt.id);
                                _showAiTipBeforeEdit(tappedTask);
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
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Extracted Helper for the All-Day list to keep build method clean
  Widget _buildAllDayList(List<Task> tasks, bool isDark) {
    final allDayTasks = tasks.where((t) => t.isAllDay || t.type == TaskType.birthday).toList();
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: allDayTasks.length >= 3 ? 115 : (allDayTasks.length * 55.0),
      ),
      child: SingleChildScrollView(
        physics: allDayTasks.length >= 3 
            ? const BouncingScrollPhysics() 
            : const NeverScrollableScrollPhysics(),
        child: Column(
          children: allDayTasks.map((task) {
            final paletteMatch = appEventColors.firstWhere(
              (c) => c.light.value == task.colorValue || c.dark.value == task.colorValue,
              orElse: () => appEventColors[0],
            );
            final Color taskColor = isDark ? paletteMatch.dark : paletteMatch.light;
            final bool isCompleted = task.status == TaskStatus.completed;
            final Color baseTextColor = ThemeData.estimateBrightnessForColor(taskColor) == Brightness.light 
                ? Colors.black87 : Colors.white;

            return GestureDetector(
              key: ValueKey(task.id), // Important for smooth list transitions
              onTap: () => _showAiTipBeforeEdit(task),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: isCompleted ? taskColor.withOpacity(0.6) : taskColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.title.isEmpty ? "Untitled" : task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    color: isCompleted ? baseTextColor.withOpacity(0.4) : baseTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- UI Helpers ---

    void _showErrorWarning(BuildContext context, String title, String message) {
      showDialog(
        context: context,
        builder: (context) => AppWarningDialog(
          title: title,
          message: message,
        ),
      );
    }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
            child: Icon(Icons.menu, size: 30, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Row(
              children: [
                Text(
                  DateFormat('MMMM').format(_selectedDate), 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
                ),
                Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
              ],
            ),
          ),
          const Spacer(),
          Icon(Icons.refresh, size: 24, color: colorScheme.onSurface),
          const SizedBox(width: 10),
          Icon(Icons.swap_vert, size: 24, color: colorScheme.onSurface),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskView())),
            child: Icon(Icons.paste, size: 24, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSidebar(ColorScheme colorScheme) {
    return Container(
      width: 60,
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('E').format(_selectedDate), 
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: colorScheme.onSurface)
          ),
          Text(
            DateFormat('d').format(_selectedDate), 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
          ),
          Icon(Icons.arrow_drop_down, size: 18, color: colorScheme.onSurface),
        ],
      ),
    );
  }

  void _handleViewChanged(ViewChangedDetails details) {
    if (details.visibleDates.isEmpty) return;
    
    final newDate = dateOnly(details.visibleDates.first);
    if (_lastRangeDate == newDate) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () { // Slightly faster debounce
      if (!mounted) return;
      
      _lastRangeDate = newDate;

      // 1. Update date
      setState(() => _selectedDate = newDate);

      // 2. Update Data Provider 
      ref.read(calendarControllerProvider.notifier).setRange(
        DateRange(scope: CalendarScope.day, startTime: newDate),
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
        enablePointerInteraction: true,
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
      ));
    }
    return regions;
  }

  Widget _buildMainFab(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildAnimatedFabOption("ReOrganize", colorScheme),
        const SizedBox(height: 10),
        _buildAnimatedFabOption("Task", colorScheme),
        const SizedBox(height: 10),
        SizedBox(
          width: 65, height: 65,
          child: FloatingActionButton(
            backgroundColor: colorScheme.primary, 
            shape: const CircleBorder(),
            onPressed: _toggleFab,
            child: AnimatedBuilder(
              animation: _fabController,
              builder: (context, child) => Transform.rotate(
                angle: _fabController.value * math.pi / 4,
                child: Icon(Icons.add, size: 32, color: colorScheme.onSurface), 
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedFabOption(String label, ColorScheme colors) {
    return ScaleTransition(
      scale: _fabAnimation, 
      alignment: Alignment.bottomRight, 
      child: FadeTransition(
        opacity: _fabAnimation, 
        child: GestureDetector(
          onTap: () {
            _toggleFab();
            if (label == "Task") {
              showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const AddTaskSheet());
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.9), 
              borderRadius: BorderRadius.circular(30)
            ),
            child: Text(
              label, 
              style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600, fontSize: 14) 
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskDataSource extends CalendarDataSource {
  _TaskDataSource(List<Task> tasks, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    appointments = tasks.map((task) {
      final Color displayColor = _resolveColor(task.colorValue, isDark);

      return Appointment(
        id: task.id,
        subject: task.title,
        startTime: task.startTime!,
        endTime: task.endTime!,
        notes: task.status == TaskStatus.completed 
            ? "[COMPLETED]${task.description ?? ''}" 
            : task.description,
        color: displayColor, 
        isAllDay: task.isAllDay,
        recurrenceRule: task.recurrenceRule,
      );
    }).toList();
  }

  Color _resolveColor(int? savedHex, bool isDark) {
    if (savedHex == null) {
      return isDark ? appEventColors[0].dark : appEventColors[0].light;
    }

    try {
      final paletteMatch = appEventColors.firstWhere(
        (c) => c.light.value == savedHex || c.dark.value == savedHex,
      );
      return isDark ? paletteMatch.dark : paletteMatch.light;
    } catch (e) {
      return Color(savedHex);
    }
  }
}