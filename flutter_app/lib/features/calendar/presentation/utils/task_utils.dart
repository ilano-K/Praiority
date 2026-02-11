import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';
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
    final taskStartTime = task.startTime!;
    final taskEndTime = task.endTime!;

    print(task.recurrenceRule);
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

      // remove seconds precision and convert to utc
      // rrule pacakge requires the use of UTC
      final startLocal = DateTime(
        taskStartTime.year,
        taskStartTime.month,
        taskStartTime.day,
        taskStartTime.hour,
        taskStartTime.minute,
        taskStartTime.second,
      );
      final startUtc = startLocal.toUtc();
      final afterUTC = startOfDay(rangeStart).toUtc();
      final beforeUTC = endOfDay(rangeEnd).toUtc();

      // If the computed "before" bound is earlier than the rule start,
      // there can be no instances — avoid calling getInstances with
      // before < start which triggers an assertion in the rrule package.
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

      print(instances);
      return instances.isNotEmpty;
    } catch (e) {
      // If there's an error parsing the recurrence rule, treat it as a non-recurring task
      return !taskEndTime.isBefore(rangeStart) &&
          !taskStartTime.isAfter(rangeEnd);
    }
  }
}
