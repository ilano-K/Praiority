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
import 'package:isar/isar.dart';


class CalendarLocalDataSource{
  final Isar isar;

  CalendarLocalDataSource(this.isar);

  // FIX: Change Parameter from TaskModel -> Task
  Future<void> saveAndUpdateTask(Task task) async {

    try {
      // 1. Create the Model from the Entity here
      final taskModel = TaskModel.fromEntity(task);
      print("[DEBUG] SAVING... THIS IS THE PRIORITY ${taskModel.priority}");
      await isar.writeTxn(() async {
        // 2. Check if task exists to preserve the Isar ID
        final existingTask = await isar.taskModels
            .filter()
            .originalIdEqualTo(task.id)
            .findFirst();

        if (existingTask != null) {
          taskModel.id = existingTask.id;
        }

        taskModel.isDeleted = false;
        taskModel.isSynced = false;
        taskModel.updatedAt = DateTime.now();
        // 3. Save the Task Model first (so it gets an ID)
        await isar.taskModels.put(taskModel);
      });
    } catch (e, st) {
      rethrow;
    }
  }
  
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
 
  Future<void> saveTag(String tag) async {
    debugPrint("[DB] Attempting to save tag: '$tag'");
    
    try {
      await isar.writeTxn(() async {
        // 1. Check if tag exists by NAME
        final existingTag = await isar.taskTagModels
            .filter()
            .nameEqualTo(tag)
            .findFirst();
        
        // 2. Prepare the model
        // We reuse the existing one to ensure we don't break unique constraints
        // or create duplicates with different IDs.
        final TaskTagModel tagToSave;
        
        if (existingTag != null) {
          debugPrint("[DB] Tag exists (ID: ${existingTag.id}). Updating...");
          tagToSave = existingTag;
          // If you have other fields to update, do it here. 
          // Since it's just a tag name, we usually don't need to do anything.
        } else {
          debugPrint("[DB] Tag is new. Creating...");
          final tagEntity = TaskTag.create(name: tag);
          tagToSave = TaskTagModel.fromEntity(tagEntity);
        }

        // 3. Persist
        await isar.taskTagModels.put(tagToSave);
        debugPrint("[DB] Tag saved successfully: ${tagToSave.name} (ID: ${tagToSave.id})");
      });
    } catch (e) {
      debugPrint("❌ [DB ERROR] Failed to save tag: $e");
      // Optional: rethrow if you want the UI to show an error
      rethrow; 
    }
  }
 
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
  // for notifcations
  Stream<List<TaskModel>> watchFutureTasks() {
    return isar.taskModels
        .filter()
        .isDeletedEqualTo(false)
        .startTimeIsNotNull()
        .startTimeGreaterThan(DateTime.now().subtract(const Duration(minutes: 1)))
        .watch(fireImmediately: true);
  }

  Future<List<TaskModel>> getTasksByRange(DateTime start, DateTime end) async {
    var q = isar.taskModels.filter().group((g) => g.startTimeBetween(start, end).or().recurrenceRuleIsNotNull());
    final tasks = await q.isDeletedEqualTo(false).sortByStartTime().findAll();
    return tasks
      .where((task) => TaskUtils.validTaskModelForDate(task, start, end))
      .toList();
  } 
  
  Future<List<TaskModel>> getTasksByCondition({
    DateTime? start, 
    DateTime? end,
    TaskCategory? category,
    TaskType? type,
    TaskStatus? status,
    String? tag,
    TaskPriority? priority,
  }) async {

    var query = isar.taskModels.filter().originalIdIsNotEmpty();

    if (category != null) query = query.categoryEqualTo(category);
    if (type != null) query = query.typeEqualTo(type);
    if (status != null) query = query.statusEqualTo(status);
    if (tag != null) query = query.tagsElementEqualTo(tag);
    if (priority != null) query = query.priorityEqualTo(priority);

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
  Future<List<TaskTagModel>> getAllTagNames() async {
    return await isar.taskTagModels.where().findAll();
  }

 
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


  Future<void> updateTasksFromCloud(List<TaskModel> cloudTasks) async {
    await isar.writeTxn(() async {
      for (var cloudTask in cloudTasks) {
        final localTask = await isar.taskModels
            .filter()
            .originalIdEqualTo(cloudTask.originalId)
            .findFirst();

        if (localTask != null) {
          // Task exists locally → update fields
          cloudTask.id = localTask.id; // preserve local Isar ID
          cloudTask.isSynced = true;
          cloudTask.status = TaskStatus.scheduled;
          cloudTask.updatedAt = DateTime.now();
        } else {
          // New task → insert as is
          cloudTask.isSynced = true;
          cloudTask.status = TaskStatus.scheduled;
          cloudTask.updatedAt = DateTime.now();
        }

        for (final tag in cloudTask.tags) {
        final existingTag = await isar.taskTagModels
            .filter()
            .nameEqualTo(tag)
            .findFirst();

        if (existingTag == null) {
          print("saving tags");
          final tagEntity = TaskTag.create(name: tag);
          final tagModel = TaskTagModel.fromEntity(tagEntity);
          await isar.taskTagModels.put(tagModel);
          }
        }
        await isar.taskModels.put(cloudTask);
      }
    });
  }

  Future<TaskModel?> getTaskById(String originalId) async {
    return await isar.taskModels.filter().originalIdEqualTo(originalId).findFirst();
  }


  Future<void> clearAllTasks() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}