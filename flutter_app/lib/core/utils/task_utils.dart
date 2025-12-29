import 'package:flutter_app/features/calendar/domain/entities/task.dart';
// File: lib/core/utils/task_utils.dart
// Purpose: Utility helpers related to task date/time and formatting.
import 'package:flutter_app/features/calendar/domain/entities/task.dart';

class TaskUtils{
  static bool taskConflict(Task a, Task b){
    return a.startTime!.isBefore(b.endTime!) && a.endTime!.isAfter(b.startTime!);
  }
}