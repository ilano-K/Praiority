import 'package:flutter_app/features/calendar/domain/entities/task.dart';

class TaskUtils{
  static bool taskConflict(Task a, Task b){
    return a.startTime!.isBefore(b.endTime!) && a.endTime!.isAfter(b.startTime!);
  }
}