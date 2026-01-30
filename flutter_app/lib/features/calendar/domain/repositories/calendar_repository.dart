import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
// File: lib/features/calendar/repository/calendar_repository.dart
// Purpose: Repository contract describing domain-facing data operations
// for calendar tasks (business-facing interface).
import 'package:flutter_app/features/calendar/domain/entities/task.dart';

abstract class CalendarRepository {
  Future<void>saveAndUpdateTask(Task task);
  Future<void>deleteTask(String id);
  Future<void> saveTag(String tag);
  Future<void> deleteTag(String tag);

  Future<List<Task>> getTasksByRange(DateTime start, DateTime end);

  Future<List<String>> getAllTagNames();
  Future<List<Task>> getTasksByCondition({DateTime? start, DateTime? end, TaskCategory? category,
                                              TaskType? type, TaskStatus? status, String? tag,
                                              });
  
}