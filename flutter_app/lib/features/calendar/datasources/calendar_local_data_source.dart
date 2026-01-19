// File: lib/features/calendar/datasources/calendar_local_data_source.dart
// Purpose: Abstract contract for local calendar data operations (CRUD + queries).
import 'package:flutter_app/features/calendar/data/models/task_tag_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import '../data/models/task_model.dart';

abstract class CalendarLocalDataSource {
  Future<void>saveAndUpdateTask(Task task);
  Future<void>deleteTask(String id);
  Future<void>saveTag(String tag);
  Future<void>deleteTag(String tag);
  
  Future<List<TaskModel>> getTasksByRange(DateTime start, DateTime end);

  Future<List<TaskModel>>getTasksByStatus(TaskStatus status);// unscheduled, scheduled, completed, past deadline wala pa
  Future<List<TaskModel>>getTasksByCategory(TaskCategory category);
  Future<List<TaskModel>>getTasksByType(TaskType type);
  Future<List<TaskModel>>getTasksByTags(String tags);

  Future<List<TaskTagModel>> getAllTagNames();
  Future<List<TaskModel>>getTasksByCondition({DateTime? start, DateTime? end, TaskCategory? category,
                                              TaskType? type, TaskStatus? status, String? tag,
                                              });
} 

