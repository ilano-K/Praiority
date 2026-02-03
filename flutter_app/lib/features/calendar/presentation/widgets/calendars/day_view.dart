import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/appointment_card.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/color_selector.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/calendars/calendar_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DayView extends ConsumerWidget {
  final List<Task> tasks;
  final CalendarController calendarController;
  final DateTime selectedDate;
  final Function(ViewChangedDetails) onViewChanged;
  final Function(Task) onTaskTap;
  final VoidCallback onDateTap;
  final List<TimeRegion> greyBlocks;

  const DayView({
    super.key,
    required this.tasks,
    required this.calendarController,
    required this.selectedDate,
    required this.onViewChanged,
    required this.onTaskTap,
    required this.onDateTap,
    required this.greyBlocks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // --- HEADER SECTION (Date Sidebar & All Day Tasks) ---
        Container(
          color: colorScheme.surface,
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalendarBuilder.buildDateSidebar(
                colorScheme: colorScheme,
                selectedDate: selectedDate,
                onTap: onDateTap,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 12, bottom: 8),
                  child: CalendarBuilder.buildAllDayList(
                    tasks: tasks,
                    isDark: isDark,
                    onTaskTap: onTaskTap,
                    selectedDate: selectedDate,
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- CALENDAR GRID SECTION ---
        Expanded(
          child: SfCalendar(
            view: CalendarView.day,
            controller: calendarController,
            headerHeight: 0,
            viewHeaderHeight: 0,
            backgroundColor: colorScheme.surface,
            // Cell borders are transparent to highlight the rounded regionBuilder blocks
            cellBorderColor: Colors.transparent, 
            
            dataSource: TaskDataSource(
              tasks.where((t) => 
                !t.isAllDay && 
                t.type != TaskType.birthday && 
                t.startTime != null
              ).toList(),
              context,
            ),

            // --- APPOINTMENT UI ---
            appointmentBuilder: (context, details) {
              return Padding(
                // Tiny padding ensures tasks don't flush against the rounded slot edges
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: AppointmentCard(appointment: details.appointments.first),
              );
            },

            // --- BACKGROUND SLOTS (Rounded Grey Blocks) ---
            specialRegions: greyBlocks,
            timeRegionBuilder: (BuildContext context, TimeRegionDetails details) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: details.region.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withOpacity(0.05) 
                        : Colors.black.withOpacity(0.05),
                    width: 1,
                  ),
                ),
              );
            },

            onViewChanged: onViewChanged,
            onTap: (CalendarTapDetails details) {
              if (details.targetElement == CalendarElement.appointment && details.appointments != null) {
                final Appointment selectedAppt = details.appointments!.first;
                final tappedTask = tasks.firstWhere((t) => t.id == selectedAppt.id);
                onTaskTap(tappedTask);
              }
            },

            // --- GRID VIEW SETTINGS ---
            timeSlotViewSettings: TimeSlotViewSettings(
              timeRulerSize: 60,
              timeTextStyle: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              // Height set to 120 for optimal text readability on short tasks
              timeIntervalHeight: 120, 
              // Helps stack overlapping stretched tasks side-by-side
              timelineAppointmentHeight: 50, 
            ),
          ),
        ),
      ],
    );
  }
}

/// TaskDataSource: Maps your domain Task entity to Syncfusion Appointment objects
class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Task> tasks, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    appointments = tasks.map((task) {
        final Color displayColor = _resolveColor(task.colorValue, isDark);
        
        // --- VISUAL STRETCHING LOGIC ---
        // We calculate a visual end time so small tasks always have 
        // room for title and description.
        DateTime visualEndTime = task.endTime!;
        final duration = task.endTime!.difference(task.startTime!);
        
        // Minimum 20 mins of vertical space for every task
        if (duration.inMinutes < 20) {
          visualEndTime = task.startTime!.add(const Duration(minutes: 20));
        }

        return Appointment(
          id: task.id,
          subject: task.title,
          startTime: task.startTime!,
          endTime: visualEndTime, 
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