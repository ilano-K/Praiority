import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart'; // Import your enums
import 'package:flutter_app/features/calendar/domain/entities/task.dart';  // Import your Task entity
import 'package:flutter_app/features/calendar/presentation/widgets/components/appointment_card.dart'; // Import your card
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/day_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// Assuming TaskDataSource is in the same file or imported
// import 'path_to_your_day_view_file.dart'; 

class WeekView extends ConsumerWidget {
  final List<Task> tasks;
  final CalendarController calendarController;
  final Function(ViewChangedDetails) onViewChanged;
  final Function(Task) onTaskTap;
  final List<TimeRegion> greyBlocks;

  const WeekView({
    super.key,
    required this.tasks,
    required this.calendarController,
    required this.onViewChanged,
    required this.onTaskTap,
    required this.greyBlocks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    // final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SfCalendar(
          view: CalendarView.week,
          controller: calendarController,
          
          // 1. Data Source & Filtering
          // Unlike DayView (where you built a custom AllDay list), in WeekView 
          // we usually pass ALL tasks and let Syncfusion handle the AllDay panel at the top.
          dataSource: TaskDataSource(
            tasks.where((t) => t.type != TaskType.birthday && t.startTime != null).toList(),
            context,
          ),

          // 2. Custom Appointment Card
          appointmentBuilder: (context, details) {
            // This renders your custom card for every appointment
            final Appointment appointment = details.appointments.first;
            return AppointmentCard(appointment: appointment);
          },

          // 3. Layout Settings
          headerHeight: 0, // Removes the "January 2026" header
          firstDayOfWeek: 7, // Sunday
          backgroundColor: colorScheme.surface,
          cellBorderColor: Colors.transparent, // Cleaner look
          
          // 4. Time Slot Styling (Matched to DayView)
          specialRegions: greyBlocks,
          timeSlotViewSettings: TimeSlotViewSettings(
            timeIntervalHeight: 80,
            timeRulerSize: 60, // Matches DayView ruler width
            timeTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: colorScheme.onSurface.withOpacity(0.7), // Adaptive color
            ),
            dayFormat: 'EEE', // "Mon", "Tue"
          ),

          // 5. Header Styling (Mon 12, Tue 13...)
          viewHeaderStyle: ViewHeaderStyle(
            dayTextStyle: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5), 
              fontSize: 12
            ),
            dateTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),

          // 6. Interactions
          onViewChanged: onViewChanged,
          onTap: (CalendarTapDetails details) {
            if (details.targetElement == CalendarElement.appointment &&
                details.appointments != null) {
              final Appointment selectedAppt = details.appointments!.first;
              
              // Find the original Task object matching the ID
              try {
                final tappedTask = tasks.firstWhere((t) => t.id == selectedAppt.id);
                onTaskTap(tappedTask);
              } catch (e) {
                print("Task not found for appointment id: ${selectedAppt.id}");
              }
            }
          },

          // 7. Selection Decoration (Optional: if you want a border when clicking empty slots)
          selectionDecoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your add logic here
        },
        backgroundColor: const Color(0xFFDDE0FF), // Or use colorScheme.primaryContainer
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}