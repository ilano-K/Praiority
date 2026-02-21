import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/utils/date_time_utils.dart';
import 'package:rrule/rrule.dart';

// File: lib/core/utils/task_utils.dart
// Purpose: Utility helpers related to task date/time and formatting.

class TaskUtils {
  static bool timeConflict(Task a, Task b) {
    if (a.startTime == null ||
        a.endTime == null ||
        b.startTime == null ||
        b.endTime == null) {
      return false;
    }

    // take time only
    final aStartTime = TimeOfDay.fromDateTime(a.startTime!);
    final aEndTime = TimeOfDay.fromDateTime(a.endTime!);

    final bStartTime = TimeOfDay.fromDateTime(b.startTime!);
    final bEndTime = TimeOfDay.fromDateTime(b.endTime!);

    return aStartTime.isBefore(bEndTime) && aEndTime.isAfter(bStartTime);
  }

  static bool validTaskModelForDate(
    Task task,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final taskStartTime = task.startTime;
    final taskEndTime = task.endTime;

    if (taskStartTime == null || taskEndTime == null) {
      return false;
    }
    // for tasks that doesn't repeat.
    if (task.recurrenceRule == "None" ||
        task.recurrenceRule == "" ||
        task.recurrenceRule == null) {
      return !taskEndTime.isBefore(rangeStart) &&
          !taskStartTime.isAfter(rangeEnd); // task fits the date range
    }

    // parse rrule
    final ruleString = task.recurrenceRule!.startsWith('RRULE:')
        ? task.recurrenceRule!
        : 'RRULE:${task.recurrenceRule!}';

    try {
      final rule = RecurrenceRule.fromString(ruleString);

      // --- THE FIX: FLOATING UTC ---
      // Instead of .toUtc() (which subtracts 8 hours), we construct a UTC
      // DateTime using the exact same local wall-clock numbers.
      final startUtc = DateTime.utc(
        taskStartTime.year,
        taskStartTime.month,
        taskStartTime.day,
        taskStartTime.hour,
        taskStartTime.minute,
        taskStartTime.second,
      );

      final afterUTC = DateTime.utc(
        rangeStart.year,
        rangeStart.month,
        rangeStart.day,
        0,
        0,
        0,
      );

      final beforeUTC = DateTime.utc(
        rangeEnd.year,
        rangeEnd.month,
        rangeEnd.day,
        23,
        59,
        59,
      );

      // If the computed "before" bound is earlier than the rule start...
      if (beforeUTC.isBefore(startUtc)) {
        return false;
      }

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

      final originalFits =
          !taskEndTime.isBefore(rangeStart) && !taskStartTime.isAfter(rangeEnd);

      return instances.isNotEmpty || originalFits;
    } catch (e) {
      // If there's an error parsing the recurrence rule, treat it as a non-recurring task
      return !taskEndTime.isBefore(rangeStart) &&
          !taskStartTime.isAfter(rangeEnd);
    }
  }
}
