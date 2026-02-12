import 'dart:async';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_app/features/calendar/domain/usecases/save_task_usecase.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/calendar/presentation/managers/smart_features_controller.dart';
import 'package:flutter_app/features/calendar/presentation/managers/task_view_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final calendarControllerProvider =
    AsyncNotifierProvider<CalendarStateController, List<Task>>(
      CalendarStateController.new,
    );

class CalendarStateController extends AsyncNotifier<List<Task>> {
  DateRange? _currentRange;

  @override
  FutureOr<List<Task>> build() {
    _currentRange ??= DateTime.now().range(CalendarScope.day);

    final repository = ref.watch(calendarRepositoryProvider);
    return repository.getTasksByRange(_currentRange!.start, _currentRange!.end);
  }

  Future<void> setRange(DateRange range, {bool forceRefresh = false}) async {
    if (!forceRefresh && _currentRange != null) {
      final isSameStart = _currentRange!.start.isAtSameMomentAs(range.start);
      final isSameEnd = _currentRange!.end.isAtSameMomentAs(range.end);

      if (isSameStart && isSameEnd) {
        print("this mf is triggering");
        return;
      }
    }

    _currentRange = range;

    final repository = ref.read(calendarRepositoryProvider);

    final updatedList = await repository.getTasksByRange(
      _currentRange!.start,
      _currentRange!.end,
    );

    print("updating list now... heres the updated list");
    print(updatedList);
    state = AsyncData(updatedList);
  }

  Future<void> refreshUi() async {
    if (_currentRange != null) {
      await setRange(_currentRange!, forceRefresh: true);

      ref.invalidate(taskViewControllerProvider);
    }
  }

  Future<void> _runSmartSchedule(Task task) async {
    final syncService = ref.read(taskSyncServiceProvider);
    final smartController = ref.read(smartFeaturesControllerProvider);

    await syncService.pushLocalChanges();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await smartController.executeSmartSchedule(task.id, today, now);

    await syncService.pullRemoteChanges();
    await refreshUi();
  }

  Future<String?> requestAiTip(String taskId) async {
    return await AsyncValue.guard(() async {
      final smartController = ref.read(smartFeaturesControllerProvider);
      return await smartController.executeSmartAdvice(taskId);
    }).then((value) {
      return value.valueOrNull;
    });
  }

  Future<void> addTask(Task task) async {
    final saveTask = ref.read(saveTaskUseCaseProvider);
    await saveTask.execute(task);

    if (task.isSmartSchedule == true) {
      await _runSmartSchedule(task);
    } else {
      final syncService = ref.read(taskSyncServiceProvider);

      await refreshUi();

      unawaited(syncService.pushLocalChanges());
    }
  }

  Future<void> reorganizeTask(DateTime targetDate, String? instruction) async {
    final smartController = ref.read(smartFeaturesControllerProvider);

    final currentTime = DateTime.now();
    await smartController.executeSmartOrganize(
      targetDate,
      currentTime,
      instruction: instruction,
    );

    final syncService = ref.read(taskSyncServiceProvider);
    await syncService.pullRemoteChanges();
    await refreshUi();
  }

  Future<void> deleteTask(Task task) async {
    final deleteTask = ref.read(deleteTaskUseCaseProvider);
    await deleteTask.execute(task);

    final currentTasks = state.value ?? [];
    final updatedList = currentTasks.where((t) => t.id != task.id).toList();
    state = AsyncData(updatedList);

    await refreshUi();
    final syncService = ref.read(taskSyncServiceProvider);
    unawaited(syncService.pushLocalChanges());
  }

  Future<void> getTasksByCondition({
    DateTime? start,
    DateTime? end,
    TaskType? type,
    TaskStatus? status,
    String? tag,
    TaskPriority? priority,
  }) async {
    final repository = ref.read(calendarRepositoryProvider);
    final updatedList = await repository.getTasksByCondition(
      start: start,
      end: end,
      type: type,
      status: status,
      tag: tag,
      priority: priority,
    );
    state = AsyncData(updatedList);
  }
}

final tagsProvider = AsyncNotifierProvider<TagsController, List<String>>(
  TagsController.new,
);

class TagsController extends AsyncNotifier<List<String>> {
  @override
  FutureOr<List<String>> build() async {
    ref.watch(calendarControllerProvider);
    final repository = ref.watch(calendarRepositoryProvider);
    return repository.getAllTagNames();
  }

  Future<void> addTag(String tag) async {
    final repository = ref.read(calendarRepositoryProvider);
    await repository.saveTag(tag);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteTag(String tag) async {
    final repository = ref.read(calendarRepositoryProvider);
    await repository.deleteTag(tag);
    ref.invalidateSelf();
    await future;
  }
}
