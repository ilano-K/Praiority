import 'package:flutter_app/features/calendar/data/models/task_tags_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import '../data/models/task_model.dart';

abstract class CalendarLocalDataSource {
  Future<void>saveAndUpdateTask(Task task);
  Future<void>deleteTask(String id);

  Future<List<TaskModel>> getTasksDay(DateTime date, {TaskStatus? status, TaskCategory? category, TaskType? type, String? tag});
  Future<List<TaskModel>> getTasksWeek(DateTime date, {TaskCategory? category, TaskType? type, String? tag});
  Future<List<TaskModel>> getTasksMonth(DateTime date, {TaskCategory? category, TaskType? type, String? tag});

  Future<List<TaskModel>>getTasksByStatus(TaskStatus status);// unscheduled, scheduled, completed, past deadline wala pa
  Future<List<TaskModel>>getTasksByCategory(TaskCategory category);
  Future<List<TaskModel>>getTasksByType(TaskType type);
  Future<List<TaskModel>>getTasksByTags(String tags);

  Future<List<TaskTagsModel>> getAllTagNames();
}

