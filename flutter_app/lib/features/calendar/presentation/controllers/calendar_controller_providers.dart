import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/calendar/presentation/utils/task_utils.dart';

final calendarControllerProvider = AsyncNotifierProvider.autoDispose.family<CalendarStateController, List<Task>, DateTime>(CalendarStateController.new);

class CalendarStateController extends AutoDisposeFamilyAsyncNotifier<List<Task>, DateTime>{
  @override
  FutureOr<List<Task>> build(DateTime arg) {
    final repository = ref.watch(calendarRepositoryProvider);
    return repository.getTasksDay(arg);
  }

  Future<void>addTask(Task task) async {
    state = const AsyncValue.loading();
    final repository = ref.read(calendarRepositoryProvider);
    state = await AsyncValue.guard(() async {
      debugPrint('addTask: called with task=${task.id}');

      final tasksForDay = await repository.getTasksDay(arg);
      debugPrint('addTask: after getTasksDay, count=${tasksForDay.length}');

      try {
        if (TaskUtils.taskConflict(tasksForDay, DateTime.now(), task)){
          debugPrint('addTask: task is conflicting with another task');
        }
        if (!TaskUtils.taskConflict(tasksForDay, DateTime.now(), task)){
          debugPrint('addTask: task is not conflicting with another task');
        }
      } catch(e){
          debugPrint("failed to check conflict. ERROR: $e");
      }

      try {
        await repository.saveAndUpdateTask(task);
        debugPrint('addTask: save complete.');
      } catch (e, st) {
        debugPrint('addTask: save failed: $e\n$st');
        rethrow;
      }

      //update week and month views
      ref.invalidate(monthControllerProvider);
      ref.invalidate(weekControllerProvider);
      return repository.getTasksDay(arg);
    });
  }
  Future<void>deleteTask(String taskId) async {
      final repository = ref.read(calendarRepositoryProvider);
      state = await AsyncValue.guard(() async {
        await repository.deleteTask(taskId);

        ref.invalidate(monthControllerProvider);
        ref.invalidate(weekControllerProvider);
        return repository.getTasksDay(arg);
      });
    }
}

final monthControllerProvider = AsyncNotifierProvider.autoDispose.family<MonthController, List<Task>, DateTime>(MonthController.new);

class MonthController extends AutoDisposeFamilyAsyncNotifier<List<Task>, DateTime>{
  @override
  FutureOr<List<Task>> build(DateTime arg) {
    final repository = ref.watch(calendarRepositoryProvider);
    return repository.getTasksMonth(arg);
  }
}

final weekControllerProvider = AsyncNotifierProvider.autoDispose.family<WeekController, List<Task>, DateTime>(WeekController.new);

class WeekController extends AutoDisposeFamilyAsyncNotifier<List<Task>, DateTime>{
  @override
  FutureOr<List<Task>> build(DateTime arg) {
    final repository = ref.watch(calendarRepositoryProvider);
    return repository.getTasksWeek(arg);
  }
}