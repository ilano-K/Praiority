import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/errors/task_conflict_exception.dart';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';

import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/calendar/presentation/utils/task_utils.dart';

final calendarControllerProvider = AsyncNotifierProvider.autoDispose.family<CalendarStateController, List<Task>, DateRange>(CalendarStateController.new);

class CalendarStateController extends AutoDisposeFamilyAsyncNotifier<List<Task>, DateRange>{
  @override
  FutureOr<List<Task>> build(DateRange arg) {
    final repository = ref.watch(calendarRepositoryProvider);
    return repository.getTasksByRange(arg.start, arg.end);
  }

  Future<void>addTask(Task task) async {
    final previous = state;
    state = const AsyncValue.loading();
    final repository = ref.read(calendarRepositoryProvider);

    final dayStart = startOfDay(task.startTime!);
    // use the task start date to compute the day's end (safer if endTime is on another day or null)
    final dayEnd = endOfDay(task.startTime!);

    debugPrint("Saving task...");
    debugPrint("Saving task: This is day start: $dayStart");
    debugPrint("Saving task: This is day end: $dayEnd");

    final tasksForDay = await repository.getTasksByRange(dayStart, dayEnd);

    debugPrint("These are the tasks for date: $dayStart");
    for(final task in tasksForDay){
      debugPrint("Task name: ${task.title}");
    }
    if (TaskUtils.checkTaskConflict(tasksForDay, dateOnly(task.startTime!), task)) {
      // restore previous state so UI doesn't stay stuck loading
      state = previous;
      throw TaskConflictException();
    }

    state = await AsyncValue.guard(() async {
      // save the task
      await repository.saveAndUpdateTask(task);

      return repository.getTasksByRange(arg.start, arg.end);
    });
  }
  Future<void>deleteTask(String taskId) async {
      final repository = ref.read(calendarRepositoryProvider);
      state = await AsyncValue.guard(() async {
        await repository.deleteTask(taskId);
        return repository.getTasksByRange(arg.start, arg.end);
      });
    }
}
