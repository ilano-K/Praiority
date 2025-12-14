import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math; 
import 'package:provider/provider.dart'; 

// IMPORTANT: Import your Widgets
import '../widgets/add_task_sheet.dart'; 
import '../widgets/appointment_card.dart'; 

// IMPORTANT: Import your ThemeProvider
import '../../../../../core/services/theme/theme_provider.dart'; 

class MainCalendar extends StatefulWidget {
  const MainCalendar({super.key});

  @override
  State<MainCalendar> createState() => _MainCalendarState();
}

class _MainCalendarState extends State<MainCalendar> with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  final CalendarController _calendarController = CalendarController();

  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  // Mock Data List
  late List<Appointment> _mockAppointments;

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

    // Initialize Mock Data
    _mockAppointments = _generateMockAppointments();
  }

  // --- Helper to Generate Mock Appointments ---
  List<Appointment> _generateMockAppointments() {
    return [
      Appointment(
        startTime: DateTime.now().copyWith(hour: 9, minute: 0),
        endTime: DateTime.now().copyWith(hour: 11, minute: 0),
        subject: "Design Meeting",
        notes: "Discuss the new UI wireframes.",
        color: const Color(0xFFF5A89A), 
        isAllDay: false,
      ),
      Appointment(
        startTime: DateTime.now().copyWith(hour: 13, minute: 0),
        endTime: DateTime.now().copyWith(hour: 14, minute: 0),
        subject: "Dev Sync",
        notes: "Daily standup with backend team.",
        color: const Color(0xFFF7B38F),
        isAllDay: false,
      ),
      // Added an 'All Day' event to show in the top cell
      Appointment(
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        subject: "Holiday",
        color: Colors.blueAccent,
        isAllDay: true,
      ),
    ];
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
                      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
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
                      // --- 1. RESTORED: Fixed Height Panel (70px) ---
                      Container(
                        padding: const EdgeInsets.only(left: 60), 
                        constraints: const BoxConstraints(minHeight: 90),
                        width: double.infinity,
                        color: colorScheme.surface,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // This will show "All Day" events if any
                          children: _buildAllDayEvents(colorScheme),
                        ),
                      ),

                      // Calendar
                      Expanded(
                        child: SfCalendar(
                          view: CalendarView.day,
                          controller: _calendarController,
                          headerHeight: 0,
                          viewHeaderHeight: 0,
                          backgroundColor: colorScheme.surface,
                          cellBorderColor: Colors.transparent,
                          
                          dataSource: AppointmentDataSource(_mockAppointments),
                          
                          appointmentBuilder: (context, calendarAppointmentDetails) {
                            final Appointment appointment = calendarAppointmentDetails.appointments.first;
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
                            if (details.targetElement == CalendarElement.appointment) {
                              // We just open the sheet. 
                              // We aren't passing the 'tappedAppointment' because AddTaskSheet
                              // doesn't accept it yet.
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const AddTaskSheet(),
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

  // --- Logic to show All Day Events in the top cell ---
  List<Widget> _buildAllDayEvents(ColorScheme colors) {
    // Filter for TODAY + ALL DAY events
    final allDayEvents = _mockAppointments.where((appt) {
      bool isToday = appt.startTime.year == _selectedDate.year &&
                     appt.startTime.month == _selectedDate.month &&
                     appt.startTime.day == _selectedDate.day;
      return isToday && appt.isAllDay;
    }).toList();

    if (allDayEvents.isEmpty) return [];

    return allDayEvents.map((appt) => AppointmentCard(appointment: appt)).toList();
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

class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}