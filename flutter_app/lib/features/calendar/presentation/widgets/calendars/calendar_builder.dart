// File: lib/features/calendar/presentation/utils/calendar_builder.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/pages/views/task_view.dart';
import 'package:flutter_app/features/calendar/presentation/utils/rrule_utils.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/color_selector.dart';
import 'package:flutter_app/features/calendar/presentation/utils/date_time_utils.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarBuilder {
  static Widget buildAppBar({
    required BuildContext context,
    required ColorScheme colorScheme,
    required DateTime selectedDate,
    required VoidCallback onPickDate,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Icon(Icons.menu, size: 30, color: colorScheme.onSurface),
            ),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: onPickDate,
            child: Row(
              children: [
                Text(
                  DateFormat('MMMM').format(selectedDate),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
              ],
            ),
          ),
          const Spacer(),

          // --- UPDATED: REFRESH ICON REPLACED WITH GOOGLE ASSET ---
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Image.asset(
              'assets/images/G.png',
              width:
                  22, // Sized slightly smaller than 24 to match visual weight
              height: 22,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TaskView()),
            ),
            child: Icon(
              Icons.assignment_outlined, // Matches your image
              size: 24,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildDateSidebar({
    required ColorScheme colorScheme,
    required DateTime selectedDate,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('E').format(selectedDate),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              DateFormat('d').format(selectedDate),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 18, color: colorScheme.onSurface),
          ],
        ),
      ),
    );
  }

  static Widget buildAllDayList({
    required List<Task> tasks,
    required bool isDark,
    required Function(Task) onTaskTap,
    required DateTime selectedDate,
  }) {
    final selectedDateOnly = dateOnly(selectedDate);
    final allDayTasks = tasks.where((t) {
      if (t.status == TaskStatus.pending) {
        return false;
      }
      if ((t.isAllDay || t.type == TaskType.birthday) && t.startTime != null) {
        final taskDateOnly = dateOnly(t.startTime!);

        // For non-recurring tasks, check exact date match
        if (t.recurrenceRule == null ||
            t.recurrenceRule == "" ||
            t.recurrenceRule == "None") {
          return taskDateOnly == selectedDateOnly;
        }

        // For recurring tasks, check if this date is within the recurring range
        // For birthdays, they repeat every year on the same month/day
        return t.startTime!.month == selectedDate.month &&
            t.startTime!.day == selectedDate.day;
      }
      return false;
    }).toList();

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
              (c) =>
                  c.light.value == task.colorValue ||
                  c.dark.value == task.colorValue,
              orElse: () => appEventColors[0],
            );
            final Color taskColor = isDark
                ? paletteMatch.dark
                : paletteMatch.light;
            final bool isCompleted = task.status == TaskStatus.completed;
            final Color baseTextColor =
                ThemeData.estimateBrightnessForColor(taskColor) ==
                    Brightness.light
                ? Colors.black87
                : Colors.white;

            return GestureDetector(
              key: ValueKey(task.id),
              behavior:
                  HitTestBehavior.opaque, // Ensures the entire bar is clickable
              onTap: () =>
                  onTaskTap(task), // Fixed: Explicitly trigger the tap logic
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isCompleted ? taskColor.withOpacity(0.6) : taskColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.title.isEmpty ? "Untitled" : task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    // UPDATED: Added Italic here
                    fontStyle: isCompleted ? FontStyle.italic : FontStyle.normal,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isCompleted
                        ? baseTextColor.withOpacity(0.4)
                        : baseTextColor,
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

  static Widget buildMainFab({
    required ColorScheme colorScheme,
    required AnimationController fabController,
    required Animation<double> fabAnimation,
    required VoidCallback onToggle,
    required Function(String) onOptionTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        // --- EXISTING BUTTONS ---
        _buildAnimatedFabOption(
          "Smart ReOrganize",
          colorScheme,
          fabAnimation,
          () => onOptionTap("ReOrganize"),
        ),
        const SizedBox(height: 10),

        // --- ADDED: SMART SCHEDULE BUTTON ---
        _buildAnimatedFabOption(
          "Smart Schedule",
          colorScheme,
          fabAnimation,
          () => onOptionTap("Smart Schedule"),
        ),
        
        
        const SizedBox(height: 10),
        _buildAnimatedFabOption(
          "Task",
          colorScheme,
          fabAnimation,
          () => onOptionTap("Task"),
        ),
        const SizedBox(height: 10),
        
        // --- FAB TOGGLE ---
        SizedBox(
          width: 65,
          height: 65,
          child: FloatingActionButton(
            backgroundColor: colorScheme.primary,
            shape: const CircleBorder(),
            onPressed: onToggle,
            child: AnimatedBuilder(
              animation: fabController,
              builder: (context, child) => Transform.rotate(
                angle: fabController.value * math.pi / 4,
                child: Icon(Icons.add, size: 32, color: colorScheme.onSurface),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildAnimatedFabOption(
    String label,
    ColorScheme colors,
    Animation<double> animation,
    VoidCallback onTap,
  ) {
    return ScaleTransition(
      scale: animation,
      alignment: Alignment.bottomRight,
      child: FadeTransition(
        opacity: animation,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
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
}

class TaskDataSource extends CalendarDataSource {
  final bool showAll; 

  TaskDataSource(List<Task> tasks, bool isDark, {this.showAll = false}) {
    _buildAppointments(tasks, isDark);
  }

  void updateData(List<Task> tasks, bool isDark) {
    _buildAppointments(tasks, isDark);
    notifyListeners(CalendarDataSourceAction.reset, appointments!);
  }

  void _buildAppointments(List<Task> tasks, bool isDark) {
    final visibleTasks = tasks.where((t) {
      if (t.status == TaskStatus.pending || t.startTime == null) return false;
      if (showAll) return true;
      return !t.isAllDay && t.type != TaskType.birthday;
    }).toList();

    appointments = visibleTasks.map((task) {
      final Color displayColor = _resolveColor(task.colorValue, isDark);
      final bool isCompleted = task.status == TaskStatus.completed;

      DateTime endTime = task.endTime ?? task.startTime!.add(const Duration(hours: 1));
      
      if (endTime.difference(task.startTime!).inMinutes < 15) {
        endTime = task.startTime!.add(const Duration(minutes: 15));
      }

      String? rRule = RRuleUtils.sanitizeRRule(task.recurrenceRule);
      if (task.type == TaskType.birthday && (rRule == null || rRule.isEmpty || rRule == 'None')) {
        rRule = 'FREQ=YEARLY';
      }

      // --- FIX: SMART DEFAULT TITLES ---
      String displayTitle = task.title;
      if (displayTitle.isEmpty) {
        switch (task.type) {
          case TaskType.birthday:
            displayTitle = "Birthday";
            break;
          case TaskType.event:
            displayTitle = "Untitled Event";
            break;
          case TaskType.task:
          default:
            displayTitle = "Untitled Task";
            break;
        }
      }

      return Appointment(
        id: task.id,
        subject: displayTitle, // <--- Now uses the smart default
        startTime: task.startTime!,
        endTime: endTime,
        notes: task.description,
        color: isCompleted ? displayColor.withOpacity(0.4) : displayColor,
        isAllDay: task.isAllDay || task.type == TaskType.birthday, 
        recurrenceRule: rRule,
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