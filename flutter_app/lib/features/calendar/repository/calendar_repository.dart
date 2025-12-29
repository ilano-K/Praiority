import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
// File: lib/features/calendar/repository/calendar_repository.dart
// Purpose: Repository contract describing domain-facing data operations
// for calendar tasks (business-facing interface).
import 'package:flutter_app/features/calendar/domain/entities/task.dart';

abstract class CalendarRepository {
  Future<void>saveAndUpdateTask(Task task);
  Future<void>deleteTask(String id);
  // check conflicting task
  Future<bool>hasConflict(Task task);

  Future<List<Task>> getTasksDay(DateTime date, {TaskStatus?status, TaskCategory? category, TaskType? type, String? tag});
  Future<List<Task>> getTasksWeek(DateTime date, {TaskCategory? category, TaskType? type, String? tag});
  Future<List<Task>> getTasksMonth(DateTime date, {TaskCategory? category, TaskType? type, String? tag});

  Future<List<Task>>getUnscheduledTasks();// unscheduled
  Future<List<Task>>getScheduledTasks();// scheduled
  Future<List<Task>>getCompletedTasks();// completed,

  Future<List<Task>>getTasksByCategory(TaskCategory category);
  Future<List<Task>>getTasksByType(TaskType type);
  Future<List<Task>>getTasksByTags(String tags);

  Future<List<String>> getAllTagNames();

  
}