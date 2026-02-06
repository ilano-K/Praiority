// File: lib/features/calendar/presentation/managers/calendar_controller.dart
import 'dart:async';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_app/features/calendar/domain/usecases/save_task_usecase.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final calendarControllerProvider = AsyncNotifierProvider<CalendarStateController, List<Task>>(CalendarStateController.new);

class CalendarStateController extends AsyncNotifier<List<Task>> {
  DateRange? _currentRange;

  @override
  FutureOr<List<Task>> build() {
    // DEBUG: Check what the initial load covers
    print("DEBUG: [Controller] build() called. Initializing default range (Today only).");
    _currentRange ??= DateTime.now().range(CalendarScope.day);
    final repository = ref.watch(calendarRepositoryProvider);
    return repository.getTasksByRange(_currentRange!.start, _currentRange!.end);
  }

  Future<void> setRange(DateRange range) async {
    _currentRange = range;
    
    // DEBUG: CRITICAL CHECK
    // This tells us exactly what dates the controller is "aware" of.
    print("DEBUG: [Controller] setRange called.");
    print("DEBUG: [Controller] Fetching from: ${range.start} to ${range.end}");

    final repository = ref.read(calendarRepositoryProvider);
    final updatedList = await repository.getTasksByRange(_currentRange!.start, _currentRange!.end);
    
    print("DEBUG: [Controller] Fetched ${updatedList.length} tasks.");
    if (updatedList.isNotEmpty) {
       // print("DEBUG: [Controller] First task date: ${updatedList.first.startTime}");
       // print("DEBUG: [Controller] Last task date: ${updatedList.last.startTime}");
    }

    state = AsyncData(updatedList);
  }

  Future<void> addTask(Task task) async {
    final saveTask = ref.read(saveTaskUseCaseProvider);
    await saveTask.execute(task);
    
    final currentTasks = state.value ?? [];
    final isEdit = currentTasks.any((t) => t.id == task.id);

    List<Task> updatedList;
    if (isEdit) {
      updatedList = currentTasks.map((t) => t.id == task.id ? task : t).toList();
    } else {
      updatedList = [...currentTasks, task];
      updatedList.sort((a, b) => (a.startTime ?? DateTime.now()).compareTo(b.startTime ?? DateTime.now()));
    }
    
    state = AsyncData(updatedList);
    final syncService = ref.read(taskSyncServiceProvider);
    unawaited(syncService.pushLocalChanges());
  }

  Future<void> deleteTask(Task task) async {
    final deleteTask = ref.read(deleteTaskUseCaseProvider);
    await deleteTask.execute(task);
    final currentTasks = state.value ?? [];
    final updatedList = currentTasks.where((t) => t.id != task.id).toList();
    state = AsyncData(updatedList);
    final syncService = ref.read(taskSyncServiceProvider);
    unawaited(syncService.pushLocalChanges());
  }

  Future<void> getTasksByCondition({
    DateTime? start, DateTime? end, TaskCategory? category,
    TaskType? type, TaskStatus? status, String? tag, TaskPriority? priority,
  }) async {
    final repository = ref.read(calendarRepositoryProvider);
    final updatedList = await repository.getTasksByCondition(
      start: start, end: end, 
      category: category, type: type, 
      status: status, tag: tag, priority: priority
    );
    state = AsyncData(updatedList);
  }
}

final tagsProvider = AsyncNotifierProvider<TagsController, List<String>>(TagsController.new);

class TagsController extends AsyncNotifier<List<String>> {
  
  @override
  FutureOr<List<String>> build() async {
    // Load the tags from the database when the app starts
    final tasksAsync = ref.watch(calendarControllerProvider);
    final repository = ref.watch(calendarRepositoryProvider);
    return repository.getAllTagNames();
  }

  Future<void> addTag(String tag) async {
    // 1. Save to Database
    final repository = ref.read(calendarRepositoryProvider);
    await repository.saveTag(tag);
    
    // 2. Refresh the State
    // This forces the build() method to run again, fetching the new list from the DB.
    // It automatically updates any UI listening to this provider.
    ref.invalidateSelf();
    
    // Note: We await the invalidation to ensure UI updates before resolving
    await future;
  }

  Future<void> deleteTag(String tag) async {
    // 1. Remove from Database
    final repository = ref.read(calendarRepositoryProvider);
    await repository.deleteTag(tag);
    
    // 2. Refresh the State
    ref.invalidateSelf();
    await future;
  }
}