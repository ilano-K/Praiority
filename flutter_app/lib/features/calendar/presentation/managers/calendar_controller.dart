import 'dart:async';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';

import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_app/features/calendar/domain/usecases/save_task_usecase.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

final calendarControllerProvider = AsyncNotifierProvider<CalendarStateController, List<Task>>(CalendarStateController.new);

class CalendarStateController extends AsyncNotifier<List<Task>>{
  DateRange? _currentRange;
  @override
  FutureOr<List<Task>> build() {
    _currentRange ??=
      DateRange(scope: CalendarScope.day, startTime: DateTime.now());
    final repository = ref.watch(calendarRepositoryProvider);
    return repository.getTasksByRange(_currentRange!.start, _currentRange!.end);
  }
  Future<void>setRange(DateRange range) async {
    _currentRange = range;
    final repository = ref.read(calendarRepositoryProvider);
    final updatedList = await repository.getTasksByRange(_currentRange!.start, _currentRange!.end);
    state = AsyncData(updatedList);
  }

  Future<void> addTask(Task task) async {
    final saveTask = ref.read(saveTaskUseCaseProvider);
    // 1. Run the heavy logic (Conflicts, Parsing, Saving)
    await saveTask.execute(task);
    // 3. Optimistic UI update (the logic you had for updatedList)
    final currentTasks = state.value ?? [];
    final isEdit = currentTasks.any((t) => t.id == task.id);

    List<Task> updatedList;
    if (isEdit) {
      updatedList = currentTasks.map((t) => t.id == task.id ? task : t).toList();
    } else {
      updatedList = [...currentTasks, task];
      updatedList.sort((a, b) => (a.startTime ?? DateTime.now()).compareTo(b.startTime ?? DateTime.now()));
    }
    
    // We return the updated list to satisfy AsyncValue.guard
    state = AsyncData(updatedList);
    final syncService = ref.read(taskSyncServiceProvider);
    unawaited(syncService.pushLocalChanges());
  }

  Future<void>deleteTask(Task task) async {
    final deleteTask = ref.read(deleteTaskUseCaseProvider);
    await deleteTask.execute(task);
    final currentTasks = state.value ?? [];
    final updatedList = currentTasks.where((t) => t.id != task.id).toList();
    state = AsyncData(updatedList);
    final syncService = ref.read(taskSyncServiceProvider);
    unawaited(syncService.pushLocalChanges());
  }

  Future<void>addTag(String tag) async {
    final repository = ref.read(calendarRepositoryProvider); 
    await repository.saveTag(tag);

    //to ensure no blinking
    final currentTasks = state.value ?? [];
    state = AsyncData(currentTasks);
  }

  Future<void>deleteTag(String tag) async {
    final repository = ref.read(calendarRepositoryProvider); 
    await repository.deleteTag(tag);
  }

  Future<void>getTasksByCondition({DateTime? start, DateTime? end, TaskCategory? category,
                                              TaskType? type, TaskStatus? status, String? tag, TaskPriority? priority,
                                              }) async {
    final repository = ref.read(calendarRepositoryProvider);
    final updatedList = await repository.getTasksByCondition(start: start, end: end, 
                                  category: category, type: type, 
                                  status: status, tag: tag, priority: priority
                                  );

    state = AsyncData(updatedList);
  }
}

