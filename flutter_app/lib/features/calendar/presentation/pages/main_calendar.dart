// File: lib/features/calendar/presentation/pages/main_calendar.dart
// Purpose: Main calendar page UI that displays day/week/month views and tasks.
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/presentation/controllers/calendar_controller_providers.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/add_birthday_sheet.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/add_event_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math; 
// Alias to avoid conflict with Riverpod

import 'package:syncfusion_flutter_calendar/calendar.dart';

// IMPORTANT: Import your Widgets
import '../widgets/add_task_sheet.dart'; 
import '../widgets/appointment_card.dart'; 

// IMPORTANT: Import your ThemeProvider
import '../../../../core/services/theme/theme_notifier.dart'; 

// IMPORTANT: Import Backend
import '../../domain/entities/task.dart';

class MainCalendar extends ConsumerStatefulWidget {
  const MainCalendar({super.key});

  @override
  ConsumerState<MainCalendar> createState() => _MainCalendarState();
}

class _MainCalendarState extends ConsumerState<MainCalendar> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = dateOnly(DateTime.now());

  //THIS IS THE ONLY RED LINE
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
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    if (_fabController.isDismissed) {
      _fabController.forward(); 
    } else {
      _fabController.reverse(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 1. WATCH THE DATABASE
    // This automatically fetches tasks for the selected date.
    // When you swipe to a new day, _selectedDate updates, and this refetches.
    DateRange dateRange = DateRange(
    scope: CalendarScope.day,
    startTime: dateOnly(_selectedDate),
    );

    final tasksAsync = ref.watch(calendarControllerProvider(dateRange));

    tasksAsync.when(
    data: (tasks) {
      if (tasks.isNotEmpty) {
        debugPrint(tasks.first.toString());
      }
    },
    loading: () {
      debugPrint('Loading...');
    },
    error: (e, st) {
      debugPrint('Error: $e');
    },
    );
    //add task logic here
    return Scaffold(
      backgroundColor: colorScheme.surface,

      // --- ANIMATED FAB ---
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAnimatedFabOption("ReOrganize", colorScheme),
          const SizedBox(height: 10),
          _buildAnimatedFabOption("Chatbot", colorScheme),
          const SizedBox(height: 10),
          _buildAnimatedFabOption("Task", colorScheme),
          const SizedBox(height: 10),
          SizedBox(
            width: 65,
            height: 65,
            child: FloatingActionButton(
              backgroundColor: colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 4,
              onPressed: _toggleFab,
              child: AnimatedBuilder(
                animation: _fabController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _fabController.value * math.pi / 4,
                    child: Icon(Icons.add, size: 32, color: colorScheme.onSurface),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // --- Top Menu Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                    child: Icon(Icons.menu, size: 30, color: colorScheme.onSurface),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => _pickDate(context),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('MMMM').format(_selectedDate),
                          style: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface
                          ),
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
                  Icon(Icons.paste, size: 24, color: colorScheme.onSurface),
                ],
              ),
            ),

            // --- Main Content Area ---
            Expanded(
              child: Stack(
                children: [
                  // LAYER 1: Scrollable Content
                  Column(
                    children: [
                      // --- 1. Fixed Height Panel (70px) ---
                      Container(
                        padding: const EdgeInsets.only(left: 60), 
                        constraints: const BoxConstraints(minHeight: 90),
                        width: double.infinity,
                        color: colorScheme.surface,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),

                      // --- 2. THE CALENDAR (Connected to Riverpod) ---
                      Expanded(
                        child: tasksAsync.when(
                          // LOADING STATE
                          loading: () => const Center(child: CircularProgressIndicator()),
                          
                          // ERROR STATE
                          error: (err, stack) => Center(child: Text("Error: $err")),
                          
                          // SUCCESS STATE
                          data: (tasks) {
                            // Filter only scheduled tasks for the calendar view
                            final scheduledTasks = tasks.where((t) => t.startTime != null && t.endTime != null).toList();

                            return SfCalendar(
                              view: CalendarView.day,
                              controller: _calendarController,
                              headerHeight: 0,
                              viewHeaderHeight: 0,
                              backgroundColor: colorScheme.surface,
                              cellBorderColor: Colors.transparent,
                              
                              // 2a. CONNECT THE DATA SOURCE
                              dataSource: _TaskDataSource(scheduledTasks),
                              
                              // 2b. USE YOUR CUSTOM CARD
                              appointmentBuilder: (context, details) {
                                final Appointment appointment = details.appointments.first;
                                return AppointmentCard(appointment: appointment);
                              },

                              specialRegions: _getGreyBlocks(colorScheme),
                              
                              onViewChanged: (ViewChangedDetails details) {
                                if (details.visibleDates.isNotEmpty) {
                                  Future.microtask(() {
                                    if (mounted && details.visibleDates.first.day != _selectedDate.day) {
                                      setState(() {
                                        _selectedDate = details.visibleDates.first;
                                      });
                                    }
                                  });
                                }
                              },

                              
                              onTap: (CalendarTapDetails details) {
                              // 1. Check if an appointment was actually tapped
                              if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
                                
                                // 2. This is currently an 'Appointment' object, not a 'Task'
                                final Appointment selectedAppt = details.appointments!.first;

                                // 3. Get the list of tasks currently loaded in the calendar
                                // We use the 'tasks' list from your tasksAsync.when(data: (tasks) => ...)
                                // If you are outside that scope, you may need to find it from the provider
                                final Task tappedTask = tasks.firstWhere((t) => t.id == selectedAppt.id);

                                // 4. Now pass the actual Task entity to the sheet
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    if (tappedTask.type == TaskType.event) {
                                      return AddEventSheet(task: tappedTask);
                                    } else if (tappedTask.type == TaskType.birthday) {
                                      return AddBirthdaySheet(task: tappedTask);
                                    } else {
                                      return AddTaskSheet(task: tappedTask);
                                    }
                                  },
                                );
                              }
                            },
                              timeSlotViewSettings: TimeSlotViewSettings(
                                timeRulerSize: 60,
                                timeTextStyle: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                timeIntervalHeight: 80,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // LAYER 2: Sidebar Overlay (Date Indicator)
                  Positioned(
                    left: 0,
                    top: 0,
                    width: 60,
                    child: Container(
                      color: Colors.transparent, 
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: GestureDetector(
                        onTap: () => _pickDate(context),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('E').format(_selectedDate), 
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('d').format(_selectedDate), 
                              style: TextStyle(
                                fontSize: 26, 
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, size: 20, color: colorScheme.onSurface),
                          ],
                        ),
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


  // --- FAB OPTION BUILDER ---
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
               showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddTaskSheet(),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Date Picker Logic ---
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calendarController.displayDate = picked;
      });
    }
  }

  // --- GAP LOGIC ---
  List<TimeRegion> _getGreyBlocks(ColorScheme colors) {
    List<TimeRegion> regions = [];
    final DateTime anchorDate = DateTime(2020, 1, 1);

    for (int i = 0; i < 24; i++) {
      regions.add(TimeRegion(
        startTime: anchorDate.copyWith(hour: i, minute: 0, second: 0),
        endTime: anchorDate.copyWith(hour: i, minute: 52, second: 0), 
        color: colors.secondary, 
        enablePointerInteraction: true,
        text: '',
        recurrenceRule: 'FREQ=DAILY;INTERVAL=1',
      ));
    }
    return regions;
  }
}

// -----------------------------------------------------------------------------
// HELPER: DATA SOURCE
// Bridges your Task Entity to Syncfusion's Appointment System
// -----------------------------------------------------------------------------
class _TaskDataSource extends CalendarDataSource {
  _TaskDataSource(List<Task> tasks) {
    appointments = tasks.map((task) {
      return Appointment(
        id: task.id,
        subject: task.title,
        startTime: task.startTime!,
        endTime: task.endTime!,
        notes: task.description,
        // You can map category to color here if needed, 
        // or let AppointmentCard handle it with transparent.
        color: Colors.transparent, 
        isAllDay: task.isAllDay,
        recurrenceRule: task.recurrenceRule
      );
    }).toList();
  }
}