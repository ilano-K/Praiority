
// File: lib/features/calendar/repository/calendar_repository_impl.dart
// Purpose: Repository implementation that mediates between domain logic
// and the local data source for calendar tasks.
import 'package:flutter_app/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/domain/repositories/calendar_repository.dart';

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
  Future<void> saveTag(String tag) async {
    await localDataSource.saveTag(tag);
  }

  @override
  Future<void> deleteTag(String tag) async {
    await localDataSource.deleteTag(tag);
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
  Future<List<Task>> getTasksByRange(DateTime start, DateTime end) async {
    final models = await localDataSource.getTasksByRange(start, end);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByCondition({DateTime? start, DateTime? end, TaskCategory? category,
                                              TaskType? type, TaskStatus? status, String? tag,
                                              }) async {
    final models = await localDataSource.getTasksByCondition(start: start, end: end, 
                                                            category: category, type: type, 
                                                            status: status, tag: tag
                                                            );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<String>> getAllTagNames() async {
    final tags = await localDataSource.getAllTagNames();
    return tags.map((t) => t.name).toList();
  }
  
}