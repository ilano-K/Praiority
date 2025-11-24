import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import '../data/models/task_model.dart';

abstract class CalendarLocalDataSource {
  Future<void>saveAndUpdateTask(TaskModel task);
  Future<void>deleteTask(String id);

  Future<List<TaskModel>> getTasksDay(DateTime date, {TaskCategory? category, TaskType? type, String? tag});
  Future<List<TaskModel>> getTasksWeek(DateTime date, {TaskCategory? category, TaskType? type, String? tag});
  Future<List<TaskModel>> getTasksMonth(DateTime date, {TaskCategory? category, TaskType? type, String? tag});

  Future<List<TaskModel>>getTasksByStatus(TaskStatus status);
  Future<List<TaskModel>>getTasksByCategory(TaskCategory category);
  Future<List<TaskModel>>getTasksByType(TaskType type);
  Future<List<TaskModel>>getTasksByTags(String tags);
}

