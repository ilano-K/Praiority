// File: lib/features/calendar/datasources/calendar_local_data_source_impl.dart
// Purpose: Isar-backed implementation of CalendarLocalDataSource.
// Handles persisting, updating, deleting tasks and linking tag models.
import 'package:flutter/foundation.dart';
import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:flutter_app/features/calendar/data/models/task_tags_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
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

        // 4. Handle Tag Linking using the ENTITY data
        if (task.tags != null && task.tags!.name.trim().isNotEmpty && task.tags!.name != 'None') {
          var tagModel = await isar.taskTagsModels
              .filter()
              .nameEqualTo(task.tags!.name)
              .findFirst();

          if (tagModel == null) {
            tagModel = TaskTagsModel.fromEntity(task.tags!);
            await isar.taskTagsModels.put(tagModel);
            debugPrint('saveAndUpdateTask: created tagModel id=${tagModel.id}');
          }

          await taskModel.tags.load();
          taskModel.tags.clear();
          taskModel.tags.add(tagModel);
          await taskModel.tags.save();
          debugPrint('saveAndUpdateTask: linked tag ${tagModel.name} to taskModel');
        }
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
      q = q.and().tags((t) => t.nameEqualTo(tag));
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
  Future<List<TaskModel>>getTasksByTags(String tags) async {
    return await isar.taskModels
        .filter()
        .tags((q) => q.nameEqualTo(tags, caseSensitive: false))
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
  Future<List<TaskTagsModel>> getAllTagNames() async {
    return await isar.taskTagsModels.where().findAll();
  }

}