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
    // 1. Get the current list of tasks to validate overlaps locally
    final List<Task> currentTasks = ref.read(calendarControllerProvider).value ?? [];

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

            onDelete: () async {
              await deleteTask(ref, task.id);
              ref.invalidate(calendarControllerProvider);
              Navigator.pop(context); 
            },

            onComplete: () async {
              final newStatus = task.status == TaskStatus.completed 
                  ? TaskStatus.scheduled 
                  : TaskStatus.completed;
              
              final updatedTask = task.copyWith(status: newStatus);

              // --- CONFLICT CHECK: Only trigger if reactivating. Ignores completed tasks ---
              if (newStatus == TaskStatus.scheduled) {
                final bool hasOverlap = currentTasks.any((t) => 
                    t.id != updatedTask.id && 
                    t.status == TaskStatus.scheduled && // Only count active tasks as obstacles
                    !t.isAllDay && !updatedTask.isAllDay && 
                    updatedTask.startTime!.isBefore(t.endTime!) &&
                    t.startTime!.isBefore(updatedTask.endTime!)
                );

                if (hasOverlap) {
                  _showErrorWarning(
                    context, 
                    "Schedule Conflict", 
                    "This time slot is taken by another active task. Adjust your time before reactivating."
                  );
                  return; // Stop execution
                }
              }

              try {
                await saveTask(ref, updatedTask);
                ref.invalidate(calendarControllerProvider);
                Navigator.pop(context);
              } on TaskConflictException {
                // This will only show if the repository validation also finds a conflict
                _showErrorWarning(
                  context, 
                  "Schedule Conflict", 
                  "This task overlaps with an existing active schedule."
                );
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      floatingActionButton: _buildMainFab(colorScheme),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, colorScheme),

            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (tasks) {
                  final allDayTasks = tasks.where((t) => t.isAllDay || t.type == TaskType.birthday).toList();
                  final scheduledTasks = tasks.where((t) => !t.isAllDay && t.type != TaskType.birthday && t.startTime != null).toList();

                  return Column(
                    children: [
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
                          child: ConstrainedBox(
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

                                  String rawTitle = task.title.trim().isEmpty ? "Birthday" : task.title;
                                  String displayTitle = rawTitle.isNotEmpty 
                                      ? "${rawTitle[0].toUpperCase()}${rawTitle.substring(1).toLowerCase()}"
                                      : "";
                                  
                                  // --- UPDATED Logic: Apply finished styling to top cards ---
                                  final bool isCompleted = task.status == TaskStatus.completed;
                                  final Color baseTextColor = ThemeData.estimateBrightnessForColor(taskColor) == Brightness.light 
                                              ? Colors.black87 : Colors.white;

                                  return GestureDetector(
                                    onTap: () => _showAiTipBeforeEdit(task),
                                    child: Container(
                                      width: double.infinity, 
                                      margin: const EdgeInsets.only(bottom: 6), 
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), 
                                      decoration: BoxDecoration(
                                        color: isCompleted ? taskColor.withOpacity(0.6) : taskColor,
                                        borderRadius: BorderRadius.circular(8), 
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        displayTitle, 
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900, 
                                          decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                          fontStyle: isCompleted ? FontStyle.italic : FontStyle.normal,
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
                          ),
                        ),
                      ),
                        ],
                      ),
                    ),
                      Expanded(
                        child: SfCalendar(
                          view: CalendarView.day,
                          controller: _calendarController,
                          headerHeight: 0,
                          viewHeaderHeight: 0,
                          backgroundColor: colorScheme.surface,
                          cellBorderColor: Colors.transparent,
                          dataSource: _TaskDataSource(scheduledTasks, context),
                          appointmentBuilder: (context, details) {
                            return AppointmentCard(appointment: details.appointments.first);
                          },
                          specialRegions: _getGreyBlocks(colorScheme.secondary), 
                          onViewChanged: _handleViewChanged,
                          onTap: (CalendarTapDetails details) {
                            if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
                              final Appointment selectedAppt = details.appointments!.first;
                              final Task tappedTask = tasks.firstWhere((t) => t.id == selectedAppt.id);
                              _showAiTipBeforeEdit(tappedTask); 
                            }
                          },
                          timeSlotViewSettings: TimeSlotViewSettings(
                            timeRulerSize: 60,
                            timeTextStyle: TextStyle(
                              color: colorScheme.onSurface, 
                              fontWeight: FontWeight.w600, 
                              fontSize: 11
                            ),
                            timeIntervalHeight: 80,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---

  void _showErrorWarning(BuildContext context, String title, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: colorScheme.onSurface)),
          ],
        ),
        content: Text(message, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() => _selectedDate = newDate);
      _lastRangeDate = newDate;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(calendarControllerProvider.notifier).setRange(DateRange(scope: CalendarScope.day, startTime: newDate));
      });
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