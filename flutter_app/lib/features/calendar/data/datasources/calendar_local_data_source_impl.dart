// File: lib/features/calendar/datasources/calendar_local_data_source_impl.dart
// Purpose: Isar-backed implementation of CalendarLocalDataSource.
// Handles persisting, updating, deleting tasks and linking tag models.
import 'package:flutter/foundation.dart';
import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:flutter_app/features/calendar/data/models/task_tag_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/domain/entities/task_tag.dart';
import 'package:flutter_app/features/calendar/presentation/utils/task_utils.dart';
import 'calendar_local_data_source.dart';
import 'package:isar/isar.dart';


class CalendarLocalDataSourceImpl implements CalendarLocalDataSource{
  final Isar isar;

  CalendarLocalDataSourceImpl(this.isar);

  @override
  // FIX: Change Parameter from TaskModel -> Task
  Future<void> saveAndUpdateTask(Task task) async {
    debugPrint('saveAndUpdateTask: start originalId=${task.id}');
    try {
      // 1. Create the Model from the Entity here
      final taskModel = TaskModel.fromEntity(task);

      await isar.writeTxn(() async {
        debugPrint('saveAndUpdateTask: in txn - checking existing task');
        // 2. Check if task exists to preserve the Isar ID
        final existingTask = await isar.taskModels
            .filter()
            .originalIdEqualTo(task.id)
            .findFirst();

        debugPrint('saveAndUpdateTask: existingTask=${existingTask?.id}');

        if (existingTask != null) {
          taskModel.id = existingTask.id;
        }

        taskModel.isDeleted = false;
        taskModel.isSynced = false;
        taskModel.updatedAt = DateTime.now();
        // 3. Save the Task Model first (so it gets an ID)
        await isar.taskModels.put(taskModel);
        debugPrint('saveAndUpdateTask: put taskModel id=${taskModel.id}');
      });

      debugPrint('saveAndUpdateTask: txn complete for originalId=${task.id}');
    } catch (e, st) {
      debugPrint('saveAndUpdateTask: ERROR $e\n$st');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteTask(String id) async{
    await isar.writeTxn(() async{
      final task = await isar.taskModels
        .filter()
        .originalIdEqualTo(id)
        .findFirst();
      if(task != null){
        task.isDeleted = true;
        task.isSynced = false;
        task.updatedAt = DateTime.now();
        print("[DEBUG]: ITS BEING DELETED NOW $id  ${task.isDeleted}");
        await isar.taskModels.put(task);
      }
    });
  }

  @override 
  Future<void> saveTag(String tag) async {
    await isar.writeTxn(() async{
      final existingTag = await isar.taskTagModels
          .filter()
          .nameEqualTo(tag)
          .findFirst();
      
      final tagEntity = TaskTag.create(name: tag);
      final tagModel = TaskTagModel.fromEntity(tagEntity);

      if(existingTag != null){
        tagModel.id = existingTag.id; // so it will update instead
      }

      await isar.taskTagModels.put(tagModel);
      debugPrint("Task tag successfully saved: ${tagModel.name}");
    });
  }

  @override 
  Future<void> deleteTag(String tag) async {
    await isar.writeTxn(() async{
      final existingTag = await isar.taskTagModels
          .filter()
          .nameEqualTo(tag)
          .findFirst();
      
      if(existingTag != null){
        final tasksWithTag = await getTasksByCondition(tag: tag);

        for(var task in tasksWithTag){
          final updatedTags = List<String>.from(task.tags ?? [])..remove(tag);
          task.tags = updatedTags;
          await isar.taskModels.put(task);
        }
        await isar.taskTagModels
          .filter()
          .originalIdEqualTo(existingTag.originalId)
          .deleteAll();
         debugPrint("Task deleted successfully deleted: ${existingTag.name}");
      }
    });
  }
  // ---------------------------------------------------------------------------
  // DATE VIEW LOGIC (CALENDAR PAGE)
  // ---------------------------------------------------------------------------
  @override
  Future<List<TaskModel>> getTasksByRange(DateTime start, DateTime end) async {
    var q = isar.taskModels.filter().group((g) => g.startTimeBetween(start, end).or().recurrenceRuleIsNotNull());
    final tasks = await q.isDeletedEqualTo(false).sortByStartTime().findAll();
    return tasks
      .where((task) => TaskUtils.validTaskModelForDate(task, start, end))
      .toList();
  } 
  @override
  Future<List<TaskModel>> getTasksByCondition({
    DateTime? start, 
    DateTime? end,
    TaskCategory? category,
    TaskType? type,
    TaskStatus? status,
    String? tag,
  }) async {

    var query = isar.taskModels.filter().originalIdIsNotEmpty();

    if (category != null) query = query.categoryEqualTo(category);
    if (type != null) query = query.typeEqualTo(type);
    if (status != null) query = query.statusEqualTo(status);
    if (tag != null) query = query.tagsElementEqualTo(tag);

    final tasks = await query.isDeletedEqualTo(false).findAll();

    if (tasks.isEmpty) return [];

    // Remove tasks without valid times
    final tasksWithTime = tasks
        .where((t) => t.startTime != null && t.endTime != null)
        .toList();

    if (tasksWithTime.isEmpty) return [];

    // Find earliest and latest safely
    DateTime earliest = tasksWithTime.first.startTime!;
    DateTime latest = tasksWithTime.first.endTime!;

    for (var t in tasksWithTime) {
      if (t.startTime!.isBefore(earliest)) earliest = t.startTime!;
      if (t.endTime!.isAfter(latest)) latest = t.endTime!;
    }

    final startRange = start ?? earliest;
    final endRange = end ?? latest;

    return tasks
        .where((task) => TaskUtils.validTaskModelForDate(task, startRange, endRange))
        .toList();
  }

  // tags
  @override
  Future<List<TaskTagModel>> getAllTagNames() async {
    return await isar.taskTagModels.where().findAll();
  }

  @override   
  Future<List<TaskModel>> getUnsyncedTasks() async {
    // Include deleted tasks so that deletions are pushed to the remote
    // backend. Previously deleted tasks were excluded by filtering
    // `isDeleted == false`, preventing the sync service from sending
    // delete updates to Supabase.
    return isar.taskModels
      .filter()
      .isSyncedEqualTo(false)
      .findAll();
  }

  @override   
  Future<void> markTasksAsSynced(String originalId) async {
    await isar.writeTxn(() async {
      final tasks = await isar.taskModels
        .filter()
        .originalIdEqualTo(originalId)
        .findAll();
      
      for(var task in tasks){
        task.isSynced = true;
        await isar.taskModels.put(task);
      }
    });
  }

  @override  
  Future<void>updateTasksFromCloud(List<TaskModel> cloudTasks) async {
    await isar.writeTxn(() async {
       for(var task in cloudTasks){
        final localTask = await isar.taskModels
        .filter()
        .originalIdEqualTo(task.originalId)
        .findFirst();

        if(localTask != null){
          task.id = localTask.id;
          task.isSynced = true;
          task.status = TaskStatus.scheduled;
          task.updatedAt = DateTime.now();
          await isar.taskModels.put(task);
        }
       }
    });
  }

}