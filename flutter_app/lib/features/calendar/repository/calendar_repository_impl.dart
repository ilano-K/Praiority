
import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:flutter_app/features/calendar/datasources/calendar_local_data_source.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/repository/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository{
  final CalendarLocalDataSource localDataSource;

  CalendarRepositoryImpl(this.localDataSource);

  @override
  Future<void> saveAndUpdateTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    await localDataSource.saveAndUpdateTask(model);
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
  Future<List<Task>> getTasksByStatus(TaskStatus status) async{
    final models = await localDataSource.getTasksByStatus(status);
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
  Future<List<Task>> getTasksDay(DateTime date, {TaskCategory? category, TaskType? type, String? tag}) async {
    final models = await localDataSource.getTasksDay(date, category: category, type: type, tag: tag);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksMonth(DateTime date, {TaskCategory? category, TaskType? type, String? tag}) async{
    final models = await localDataSource.getTasksMonth(date, category: category, type: type, tag: tag);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksWeek(DateTime date, {TaskCategory? category, TaskType? type, String? tag}) async{
    final models = await localDataSource.getTasksWeek(date, category: category, type: type, tag: tag);
    return models.map((model) => model.toEntity()).toList();
  }
  
}