// File: lib/features/calendar/datasources/calendar_local_data_source_impl.dart
// Purpose: Isar-backed implementation of CalendarLocalDataSource.
// Handles persisting, updating, deleting tasks and linking tag models.
import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:flutter_app/features/calendar/data/models/task_tags_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'calendar_local_data_source.dart';
import 'package:isar/isar.dart';


class CalendarLocalDataSourceImpl implements CalendarLocalDataSource{
  final Isar isar;

  CalendarLocalDataSourceImpl(this.isar);

  @override
  // FIX: Change Parameter from TaskModel -> Task
  Future<void> saveAndUpdateTask(Task task) async {
    // 1. Create the Model from the Entity here
    final taskModel = TaskModel.fromEntity(task);

    await isar.writeTxn(() async {
      // 2. Check if task exists to preserve the Isar ID
      final existingTask = await isar.taskModels
          .filter()
          .originalIdEqualTo(task.id)
          .findFirst();

      if (existingTask != null) {
        taskModel.id = existingTask.id;
      }

      // 3. Save the Task Model first (so it gets an ID)
      await isar.taskModels.put(taskModel);

      // 4. Handle Tag Linking using the ENTITY data
      // If the task has a tag name (and it's not a placeholder like 'None'),
      // attempt to find an existing tag; if none exists, create it and link.
      if (task.tags != null && task.tags!.name.trim().isNotEmpty && task.tags!.name != 'None') {
        var tagModel = await isar.taskTagsModels
            .filter()
            .nameEqualTo(task.tags!.name)
            .findFirst();

        if (tagModel == null) {
          tagModel = TaskTagsModel.fromEntity(task.tags!);
          await isar.taskTagsModels.put(tagModel);
        }

        await taskModel.tags.load();
        taskModel.tags.clear();
        taskModel.tags.add(tagModel);
        await taskModel.tags.save();
      }
    });
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
  Future<List<TaskModel>> getTasksDay(
    DateTime date,{
      TaskStatus? status, 
      TaskCategory? category, 
      TaskType? type,
      String? tag
    }
    ) async {
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

    var q = isar.taskModels.filter().startTimeBetween(startOfDay, endOfDay);

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
    return await q.sortByStartTime().findAll();
  }

  @override
  Future<List<TaskModel>> getTasksWeek(
    DateTime date,{
      TaskCategory? category, 
      TaskType? type,
      String? tag
    }
    ) async {
    // Start of the week (Monday)
    final startOfWeek = DateTime(
      date.year,
      date.month,
      date.day - (date.weekday - 1),
    );

    // End of the week (Sunday)
    final endOfWeek = startOfWeek
        .add(const Duration(days: 7))
        .subtract(const Duration(seconds: 1));

    var q = isar.taskModels.filter().startTimeBetween(startOfWeek, endOfWeek);

    if (category != null){
      q = q.and().categoryEqualTo(category);
    }

    if (type != null){
      q = q.and().typeEqualTo(type);
    }

    if (tag != null) {
      q = q.and().tags((t) => t.nameEqualTo(tag));
    }
    return await q.sortByStartTime().findAll();
  }
  // get tasks for the month
  @override
  Future<List<TaskModel>> getTasksMonth(
    DateTime date,{
      TaskCategory? category, 
      TaskType? type,
      String? tag
    }
    ) async {
    // Current day (00:00:00)
    final startOfMonth = DateTime(date.year, date.month, 1);

    // Handling for december
    final startOfNextMonth = DateTime(date.year, date.month + 1, 1);
    final endOfMonth = startOfNextMonth.subtract(const Duration(seconds: 1));
    
    var q = isar.taskModels.filter().startTimeBetween(startOfMonth, endOfMonth);

    if (category != null){
      q = q.and().categoryEqualTo(category);
    }

    if (type != null){
      q = q.and().typeEqualTo(type);
    }

    if (tag != null) {
      q = q.and().tags((t) => t.nameEqualTo(tag));
    }
    return await q.sortByStartTime().findAll();
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