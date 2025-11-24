import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';

abstract class CalendarRepository {
  Future<void>saveAndUpdateTask(Task task);
  Future<void>deleteTask(String id);
  
  Future<List<Task>> getTasksDay(DateTime date, {TaskCategory? category, TaskType? type, String? tag});
  Future<List<Task>> getTasksWeek(DateTime date, {TaskCategory? category, TaskType? type, String? tag});
  Future<List<Task>> getTasksMonth(DateTime date, {TaskCategory? category, TaskType? type, String? tag});

  Future<List<Task>>getTasksByStatus(TaskStatus status);
  Future<List<Task>>getTasksByCategory(TaskCategory category);
  Future<List<Task>>getTasksByType(TaskType type);
  Future<List<Task>>getTasksByTags(String tags);
}