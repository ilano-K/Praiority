import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'calendar_local_data_source.dart';
import 'package:isar/isar.dart';


class CalendarLocalDataSourceImpl implements CalendarLocalDataSource{
  final Isar isar;

  CalendarLocalDataSourceImpl(this.isar);

  @override
  Future<void> saveAndUpdateTask(TaskModel task) async{
    await isar.writeTxn(() async{
      final existingTask = await isar.taskModels
          .filter()
          .originalIdEqualTo(task.originalId)
          .findFirst();
      // update instead
      if(existingTask != null)  {
        task.id = existingTask.id;
      }
      await isar.taskModels.put(task);
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

    if (tag != null){
      q = q.and().tagsElementEqualTo(tag);
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

    if (tag != null){
      q = q.and().tagsElementEqualTo(tag);
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

    if (tag != null){
      q = q.and().tagsElementEqualTo(tag);
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
        .tagsElementEqualTo(tags)
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

  

  // get tasks for today

}