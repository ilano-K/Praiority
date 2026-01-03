
// File: lib/features/calendar/repository/calendar_repository_impl.dart
// Purpose: Repository implementation that mediates between domain logic
// and the local data source for calendar tasks.
import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:flutter_app/features/calendar/datasources/calendar_local_data_source.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/repository/calendar_repository.dart';
import 'package:flutter_app/features/calendar/presentation/utils/task_utils.dart';

class CalendarRepositoryImpl implements CalendarRepository{
  final CalendarLocalDataSource localDataSource;

  CalendarRepositoryImpl(this.localDataSource);

  @override
  Future<void> saveAndUpdateTask(Task task) async {
    // final model = TaskModel.fromEntity(task);
    await localDataSource.saveAndUpdateTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await localDataSource.deleteTask(id);
  }

  @override
  Future<List<Task>> getTasksByCategory(TaskCategory category) async {
    final models = await localDataSource.getTasksByCategory(category);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getUnscheduledTasks() async{
    final models = await localDataSource.getTasksByStatus(TaskStatus.unscheduled);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getScheduledTasks() async{
    final models = await localDataSource.getTasksByStatus(TaskStatus.scheduled);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getCompletedTasks() async{
    final models = await localDataSource.getTasksByStatus(TaskStatus.completed);
    return models.map((model) => model.toEntity()).toList();
  }


  @override
  Future<List<Task>> getTasksByTags(String tags) async {
    final models = await localDataSource.getTasksByTags(tags);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByType(TaskType type) async {
    final models = await localDataSource.getTasksByType(type);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksDay(DateTime date, {TaskStatus?status, TaskCategory? category, TaskType? type, String? tag}) async {
    final startDay = TaskUtils.startOfDay(date);
    final endDay = TaskUtils.endOfDay(date);
    final models = await localDataSource.getTasksDay(date, category: category, type: type, tag: tag);
    return TaskUtils.filterValidTasksForDate(models.map(
      (model) => model.toEntity()).toList(), 
      startDay, 
      endDay);
  }

  @override
  Future<List<Task>> getTasksMonth(DateTime date, {TaskCategory? category, TaskType? type, String? tag}) async{
    final startMonth = TaskUtils.startOfMonth(date);
    final endMonth = TaskUtils.endOfMonth(date);
    final models = await localDataSource.getTasksMonth(startMonth, endMonth, category: category, type: type, tag: tag);
    return TaskUtils.filterValidTasksForDate(models.map(
      (model) => model.toEntity()).toList(), 
      startMonth, 
      endMonth);
  }

  @override
  Future<List<Task>> getTasksWeek(DateTime date, {TaskCategory? category, TaskType? type, String? tag}) async{
    final startWeek = TaskUtils.startOfWeek(date);
    final endWeek = TaskUtils.endOfWeek(date);
    final models = await localDataSource.getTasksWeek(startWeek, endWeek, category: category, type: type, tag: tag);
    return TaskUtils.filterValidTasksForDate(models.map(
      (model) => model.toEntity()).toList(), 
      startWeek, 
      endWeek);
  }

  @override
  Future<List<String>> getAllTagNames() async {
    final tags = await localDataSource.getAllTagNames();
    return tags.map((t) => t.name).toList();
  }
  
}