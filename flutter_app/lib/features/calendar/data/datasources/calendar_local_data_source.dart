// File: lib/features/calendar/datasources/calendar_local_data_source.dart
// Purpose: Abstract contract for local calendar data operations (CRUD + queries).
import 'package:flutter_app/features/calendar/data/models/task_tag_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import '../models/task_model.dart';

abstract class CalendarLocalDataSource {
  Future<void>saveAndUpdateTask(Task task);
  Future<void>deleteTask(String id);
  Future<void>saveTag(String tag);
  Future<void>deleteTag(String tag);
  
  Future<List<TaskModel>> getTasksByRange(DateTime start, DateTime end);
  Future<List<TaskTagModel>> getAllTagNames();
  Future<List<TaskModel>>getTasksByCondition({DateTime? start, DateTime? end, TaskCategory? category,
                                              TaskType? type, TaskStatus? status, String? tag, TaskPriority? priority,
                                              });

  // cloud 
  Future<List<TaskModel>> getUnsyncedTasks();
  Future<void>markTasksAsSynced(String originalId);
  Future<void>updateTasksFromCloud(List<TaskModel> cloudTasks);
  Future<void> clearAllTasks();
} 

