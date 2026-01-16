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
      await isar.taskModels
        .filter()
        .originalIdEqualTo(id)
        .deleteAll();
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
        final tasksWithTag = await getTasksByTags(tag);

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
  Future<List<TaskModel>> getTasksByRange(
    DateTime start, DateTime end,{
      TaskStatus? status, 
      TaskCategory? category, 
      TaskType? type,
      String? tag
    }
    ) async {
    var q = isar.taskModels.filter().group((g) => g.startTimeBetween(start, end).or().recurrenceRuleIsNotNull());

    // optional filters
    if (status != null){
      q = q.and().statusEqualTo(status);
    }

    if (category != null){
      q = q.and().categoryEqualTo(category);
    }

    if (type != null){
      q = q.and().typeEqualTo(type);
    }

    if (tag != null) {
      q = q.and().tagsElementEqualTo(tag);
    }

    final tasks = await q.sortByStartTime().findAll();

    return tasks
      .where((task) => TaskUtils.validTaskModelForDate(task, start, end))
      .toList();
  } 

  // ---------------------------------------------------------------------------
  // FILTER LOGIC
  // ---------------------------------------------------------------------------

  @override
  Future<List<TaskModel>>getTasksByTags(String tag) async {
    return await isar.taskModels
        .filter()
        .tagsElementEqualTo(tag)
        .sortByStartTime()
        .findAll();
  }

  // get by type (tasks or events)
  @override
  Future<List<TaskModel>>getTasksByType(TaskType type) async {
    return await isar.taskModels
        .filter()
        .typeEqualTo(type)
        .sortByStartTime()
        .findAll();
  }

  // get by category (focus, active, lightweight ata)
  @override
  Future<List<TaskModel>>getTasksByCategory(TaskCategory category) async {
    return await isar.taskModels
        .filter()
        .categoryEqualTo(category)
        .sortByStartTime()
        .findAll();
  }

  // get unsched, sched, and completed tasks
  @override
  Future<List<TaskModel>>getTasksByStatus(TaskStatus status) async {
    return await isar.taskModels
        .filter()
        .statusEqualTo(status)
        .sortByStartTime()
        .findAll();
  }

  // tags
  @override
  Future<List<TaskTagModel>> getAllTagNames() async {
    return await isar.taskTagModels.where().findAll();
  }

}