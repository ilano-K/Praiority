import 'package:flutter/foundation.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import  'package:rrule/rrule.dart';

// File: lib/core/utils/task_utils.dart
// Purpose: Utility helpers related to task date/time and formatting.

class TaskUtils{
  static bool taskConflict(List<Task> tasks, DateTime date, Task taskToSchedule){
    for(final task in tasks){
      // normal tasks have reccurence rule as null
      // take normal tasks and other tasks that occur on the specified date.
      if(task.recurrenceRule == null || occursOnDate(task, date)){
        if (timeConflict(taskToSchedule, task)){
          return true; 
        }
      }
    }
    return false;
  }

  static bool timeConflict(Task a, Task b){
    return a.startTime!.isBefore(b.endTime!) && a.endTime!.isAfter(b.startTime!);
  }

  // check if a recurring task occurs on the specified date
  static bool occursOnDate(Task task, DateTime date){
    //task has no recurrence rule 
    if(task.recurrenceRule == "None" || task.recurrenceRule == "" || task.recurrenceRule == null){
      return false; // non-recurring
    }

    //parse RRULE as per requirement
    final ruleString = task.recurrenceRule!.startsWith('RRULE:')
      ? task.recurrenceRule!
      : 'RRULE:${task.recurrenceRule!}';

    //take the recurrence rule
    final rule = RecurrenceRule.fromString(ruleString);
    
    final taskStartTime = task.startTime;

    if (taskStartTime == null) return false;

    // rrule package requires a DateTime in a valid RRULE form. Normalize the
    // start to second precision and use UTC for the `start` argument because
    // the library's validation expects an appropriate timezone form. Use UTC
    // for the range bounds as well so comparisons align.
    final sanitizedStartLocal = DateTime(
      taskStartTime.year,
      taskStartTime.month,
      taskStartTime.day,
      taskStartTime.hour,
      taskStartTime.minute,
      taskStartTime.second,
    );
    final sanitizedStartUtc = sanitizedStartLocal.toUtc();

    final dayStartUtc = startOfDay(date).toUtc();
    final dayEndUtc = endOfDay(date).toUtc();

    // Ensure `after` passed to getInstances is not before `start` (the
    // rrule package asserts `after >= start`). Use the later of
    // dayStartUtc-1s and sanitizedStartUtc.
    DateTime afterArg = dayStartUtc.subtract(const Duration(seconds: 1));
    if (afterArg.isBefore(sanitizedStartUtc)) {
      afterArg = sanitizedStartUtc;
    }

    // check if there is an occurrence of the task on the specified date.
    final instances = rule.getInstances(
      start: sanitizedStartUtc,
      after: afterArg,
      before: dayEndUtc,
      includeAfter: true,
    );

    debugPrint('occursOnDate: instances found=${instances.length} for task=${task.title} on $date');
    return instances.isNotEmpty;
  }

  // helpers
  static DateTime startOfDay(DateTime date){
    return DateTime(date.year, date.month, date.day);
  }
  static DateTime endOfDay(DateTime date){
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
}