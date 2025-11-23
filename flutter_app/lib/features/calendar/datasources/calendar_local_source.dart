import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:isar/isar.dart';
import '../data/models/task_model.dart';
import 'package:flutter_app/features/calendar/data/models/task_model.dart';

abstract class CalendarLocalDataSource {
  // Create
  Future<void>saveAndUpdateTask(TaskModel task);

  // Read
  Future<List<TaskModel>> getTasksDay(DateTime date);
  Future<List<TaskModel>> getTasksWeek(DateTime date);
  Future<List<TaskModel>> getTasksMonth(DateTime date);
  //unscheduled, scheudled, completed here:

  
  //Update
  // Future<void>updateTask(TaskModel task);
  // Delete
  Future<void>deleteTask(String id);

}

class CalendarLocalDataSourceImpl implements CalendarLocalDataSource{
  final Isar isar;

  CalendarLocalDataSourceImpl(this.isar);

  // get tasks for today
  @override
  Future<List<TaskModel>> getTasksDay(DateTime date) async {
    // Start of the day (00:00:00)
    final startOfDay = DateTime(date.year, date.month, date.day);

    // End of the day, subtracts 1 second to next day VOILA!!!
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

    //QUERY
    return await isar.taskModels
        .filter()
        .startTimeBetween(startOfDay, endOfDay)
        .sortByStartTime()
        .findAll();
  }

  // get tasks for the week
  @override
  Future<List<TaskModel>> getTasksWeek(DateTime date) async {
    // Current day (00:00:00)
    final currentDay = DateTime(date.year, date.month, 1);

    // After a week 
    final endOfWeek = currentDay.add(const Duration(days: 6));

    return await isar.taskModels
        .filter()
        .startTimeBetween(currentDay, endOfWeek)
        .sortByStartTime()
        .findAll();
  }
  
  // get tasks for the month
  @override
  Future<List<TaskModel>> getTasksMonth(DateTime date) async {
    // Current day (00:00:00)
    final currentDay = DateTime(date.year, date.month, 1);

    // Handling for december
    final startOfNextMonth = (date.month < 12) 
      ? DateTime(date.year, date.month + 1, 1) 
      : DateTime(date.year + 1, 1, 1);
    
    final endOfMonth = startOfNextMonth.subtract(const Duration(seconds: 1));

    return await isar.taskModels
        .filter()
        .startTimeBetween(currentDay, endOfMonth)
        .sortByStartTime()
        .findAll();
  }
  
 
  // create and automatically 
  @override
  Future<void> saveAndUpdateTask(TaskModel task) async{
    await isar.writeTxn(() async{
      final existingTask = await isar.taskModels
          .filter()
          .originalIdEqualTo(task.originalId)
          .findFirst();
      if(existingTask != null)  {
        task.id = existingTask.id;
      }
      await isar.taskModels.put(task);
    });
    throw UnimplementedError();
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
}