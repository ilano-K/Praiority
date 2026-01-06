// File: lib/features/calendar/datasources/calendar_local_data_source.dart
// Purpose: Abstract contract for local calendar data operations (CRUD + queries).
import 'package:flutter_app/features/calendar/data/models/task_tags_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import '../data/models/task_model.dart';

abstract class CalendarLocalDataSource {
  Future<void>saveAndUpdateTask(Task task);
  Future<void>deleteTask(String id);
  
  Future<List<TaskModel>> getTasksByRange(DateTime start, DateTime end, {TaskStatus? status, TaskCategory? category, TaskType? type, String? tag});

  Future<List<TaskModel>>getTasksByStatus(TaskStatus status);// unscheduled, scheduled, completed, past deadline wala pa
  Future<List<TaskModel>>getTasksByCategory(TaskCategory category);
  Future<List<TaskModel>>getTasksByType(TaskType type);
  Future<List<TaskModel>>getTasksByTags(String tags);

  Future<List<TaskTagsModel>> getAllTagNames();
}

