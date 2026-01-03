import 'package:flutter/foundation.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import  'package:rrule/rrule.dart';

// File: lib/core/utils/task_utils.dart
// Purpose: Utility helpers related to task date/time and formatting.

class TaskUtils{
  static bool taskConflict(List<Task> tasks, DateTime date, Task taskToSchedule){
    for (final task in tasks) {
      if (task.id == taskToSchedule.id) continue;
      if (timeConflict(task, taskToSchedule)) return true;
    }
    return false;
  }

  static bool timeConflict(Task a, Task b){
    if (a.startTime == null || a.endTime == null || b.startTime == null || b.endTime == null) {
      return false;
    }
    return a.startTime!.isBefore(b.endTime!) && a.endTime!.isAfter(b.startTime!);
  }

  static List<Task> filterValidTasksForDate(List<Task> tasks, DateTime rangeStart, DateTime rangeEnd){
    return tasks
      .where((task) => validTaskForDate(task, rangeStart, rangeEnd))
      .toList();
  }

  static bool validTaskForDate(Task task, DateTime rangeStart , DateTime rangeEnd){
    final taskStartTime = task.startTime!;
    final taskEndTime = task.endTime!;

    // for tasks that doesn't repeat.
    if(task.recurrenceRule == "None" || task.recurrenceRule == "" || task.recurrenceRule == null){
      return !taskEndTime.isBefore(rangeStart) && !taskStartTime.isAfter(rangeEnd); // task fits the date range 
    }

    // parse rrule 
    final ruleString = task.recurrenceRule!.startsWith('RRULE:') ? task.recurrenceRule! : 'RRULE:${task.recurrenceRule!}';
    final rule = RecurrenceRule.fromString(ruleString);

    // remove seconds precision and convert to utc
    // rrule pacakge requires the use of UTC
    final startLocal = DateTime(
      taskStartTime.year, taskStartTime.month, taskStartTime.day,
      taskStartTime.hour, taskStartTime.minute,taskStartTime.second,
    );
    final startUtc = startLocal.toUtc();
    final afterUTC = startOfDay(rangeStart).toUtc();
    final beforeUTC = endOfDay(rangeEnd).toUtc();

    DateTime afterArg = afterUTC.subtract(const Duration(seconds: 1));
    if (afterArg.isBefore(startUtc)) {
      afterArg = startUtc;
    }

    final instances = rule.getInstances(
      start: startUtc,
      after: afterArg,
      before: beforeUTC,
      includeAfter: true,
    );

    return instances.isNotEmpty;
  }

  // helpers
  static DateTime startOfDay(DateTime date){
    return DateTime(date.year, date.month, date.day);
  }
  static DateTime endOfDay(DateTime date){
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }
  static DateTime endOfWeek(DateTime date) {
    final sunday = date.add(Duration(days: 7 - date.weekday));
    return DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1); 
  }
  static DateTime endOfMonth(DateTime date) {
    final firstOfNextMonth = (date.month < 12) 
        ? DateTime(date.year, date.month + 1, 1)
        : DateTime(date.year + 1, 1, 1); // handle December
    return firstOfNextMonth.subtract(const Duration(seconds: 1));
  }
}