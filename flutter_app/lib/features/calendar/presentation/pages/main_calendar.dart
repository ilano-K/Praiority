// File: lib/features/calendar/presentation/pages/main_calendar.dart
// Purpose: Main calendar page UI with side-by-side layout, scrollable header, and custom theme integration.
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/presentation/controllers/calendar_controller_providers.dart';
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
import 'task_view.dart';

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
            // --- 1. Top Navigation Menu ---
            _buildAppBar(context, colorScheme),

            // --- 2. Main Content (Sidebar + Calendar) ---
            Expanded(
              child: tasksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (tasks) {
                  final allDayTasks = tasks.where((t) => t.isAllDay || t.type == TaskType.birthday).toList();
                  final scheduledTasks = tasks.where((t) => !t.isAllDay && t.type != TaskType.birthday && t.startTime != null).toList();

                  return Column(
                    children: [
                      // --- HEADER ROW (RESTORED TO GREEN) ---
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
                          // 1. DYNAMIC HEIGHT: We use ConstrainedBox so it grows with tasks 
                          // but caps out at roughly 2.5 tasks (115px) to trigger scrolling.
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: allDayTasks.length >= 3 ? 115 : (allDayTasks.length * 55.0),
                            ),
                            child: SingleChildScrollView(
                              // Only allow scrolling if there are 3 or more tasks
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

                                  // 2. TEXT FORMATTING: Handle empty titles and force Title Case
                                  String rawTitle = task.title.trim().isEmpty ? "Birthday" : task.title;
                                  String displayTitle = rawTitle.isNotEmpty 
                                      ? "${rawTitle[0].toUpperCase()}${rawTitle.substring(1).toLowerCase()}"
                                      : "";

                                  return GestureDetector(
                                    onTap: () => _openTaskSheet(task),
                                    child: Container(
                                      width: double.infinity, 
                                      margin: const EdgeInsets.only(bottom: 6), 
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), 
                                      decoration: BoxDecoration(
                                        color: taskColor,
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
                                          color: ThemeData.estimateBrightnessForColor(taskColor) == Brightness.light 
                                              ? Colors.black87 : Colors.white,
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
                      // --- CALENDAR GRID ---
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
                          // Reverted hourly slots back to your Theme's Secondary (DFDFDF or 3A3A3A)
                          specialRegions: _getGreyBlocks(colorScheme.secondary), 
                          onViewChanged: _handleViewChanged,
                          onTap: (CalendarTapDetails details) {
                            if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
                              final Appointment selectedAppt = details.appointments!.first;
                              final Task tappedTask = tasks.firstWhere((t) => t.id == selectedAppt.id);
                              _openTaskSheet(tappedTask); 
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

  // --- UI Component Builders ---

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

  // --- Logic & Helpers ---

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

// At the bottom of main_calendar.dart
class _TaskDataSource extends CalendarDataSource {
  _TaskDataSource(List<Task> tasks, BuildContext context) {
    // Detect the current theme mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    appointments = tasks.map((task) {
      // 1. Resolve the color by looking it up in your appEventColors list
      final Color displayColor = _resolveColor(task.colorValue, isDark);

      return Appointment(
        id: task.id,
        subject: task.title,
        startTime: task.startTime!,
        endTime: task.endTime!,
        notes: task.description,
        // 2. Pass the resolved color (swaps automatically when theme changes)
        color: displayColor, 
        isAllDay: task.isAllDay,
        recurrenceRule: task.recurrenceRule,
      );
    }).toList();
  }

  // Helper logic to find the palette pair
  Color _resolveColor(int? savedHex, bool isDark) {
    if (savedHex == null) {
      return isDark ? appEventColors[0].dark : appEventColors[0].light;
    }

    try {
      // Find which pair in your list matches the saved hex code
      final paletteMatch = appEventColors.firstWhere(
        (c) => c.light.value == savedHex || c.dark.value == savedHex,
      );
      
      // Return the variant for the current system theme
      return isDark ? paletteMatch.dark : paletteMatch.light;
    } catch (e) {
      // Fallback if the color isn't in your appEventColors list
      return Color(savedHex);
    }
  }
}