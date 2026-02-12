import 'dart:async';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_app/features/calendar/domain/usecases/save_task_usecase.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final taskViewControllerProvider =
    AsyncNotifierProvider.autoDispose<TaskViewStateController, List<Task>>(
      TaskViewStateController.new,
    );

class TaskViewStateController extends AutoDisposeAsyncNotifier<List<Task>> {
  @override
  FutureOr<List<Task>> build() async {
    // Initial load: Get all tasks (or pending)
    return fetchTasks();
  }

  Future<List<Task>> fetchTasks({
    DateTime? start,
    DateTime? end,
    TaskCategory? category,
    TaskPriority? priority,
    String? tag,
  }) async {
    final repository = ref.read(calendarRepositoryProvider);
    return repository.getTasksByCondition(
      start: start,
      end: end,
      priority: priority,
      tag: tag,
    );
  }

  // Use this for sorting/filtering inside Task View
  Future<void> filterTasks({
    DateTime? start,
    DateTime? end,
    TaskCategory? category,
    TaskPriority? priority,
    String? tag,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => fetchTasks(
        start: start,
        end: end,
        category: category,
        priority: priority,
        tag: tag,
      ),
    );
  }

  Future<void> updateTask(Task task) async {
    final saveTask = ref.read(saveTaskUseCaseProvider);
    await saveTask.execute(task);

    // 1. Update Local TaskView State (Optimistic)
    final currentTasks = state.value ?? [];
    final updatedList = currentTasks
        .map((t) => t.id == task.id ? task : t)
        .toList();

    // Re-sort if needed
    updatedList.sort(
      (a, b) => (a.startTime ?? DateTime.now()).compareTo(
        b.startTime ?? DateTime.now(),
      ),
    );
    state = AsyncData(updatedList);

    // 2. IMPORTANT: Tell the Main Calendar it needs to refresh next time it's seen
    ref.invalidate(calendarControllerProvider);

    // 3. Sync
    final syncService = ref.read(taskSyncServiceProvider);
    unawaited(syncService.pushLocalChanges());
  }

  Future<void> deleteTask(Task task) async {
    final deleteTask = ref.read(deleteTaskUseCaseProvider);
    await deleteTask.execute(task);

    // 1. Update Local TaskView State
    final currentTasks = state.value ?? [];
    final updatedList = currentTasks.where((t) => t.id != task.id).toList();
    state = AsyncData(updatedList);

    // 2. Invalidate Main Calendar
    ref.invalidate(calendarControllerProvider);

    // 3. Sync
    final syncService = ref.read(taskSyncServiceProvider);
    unawaited(syncService.pushLocalChanges());
  }
}
