import 'dart:async';

import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final calendarControllerProvider = AsyncNotifierProvider.autoDispose.family<CalendarController, List<Task>, DateTime>(CalendarController.new);

class CalendarController extends AutoDisposeFamilyAsyncNotifier<List<Task>, DateTime>{
  @override
  FutureOr<List<Task>> build(DateTime arg) {
    final repository = ref.watch(calendarRepositoryProvider);
    return repository.getTasksDay(arg);
  }

  Future<void>addTask(Task task) async {
    state = const AsyncValue.loading();
    final repository = ref.read(calendarRepositoryProvider);
    state = await AsyncValue.guard(() async {
      //add conflict logic + exception to catch.

      await repository.saveAndUpdateTask(task);

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