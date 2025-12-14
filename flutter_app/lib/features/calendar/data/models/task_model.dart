import 'package:flutter_app/features/calendar/domain/entities/enums.dart';

import '../../domain/entities/task.dart';

import 'package:isar/isar.dart';

part 'task_model.g.dart';

@Collection()
class TaskModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String originalId;

  @Enumerated(EnumType.name)
  late TaskType type;

  @Enumerated(EnumType.name)
  late TaskCategory category;

  late List<String> tags;

  late String title;

  String? description;
  String? location;

  DateTime? startTime; 
  DateTime? endTime; 
  DateTime? deadline; 
  int? durationMinutes;

  late bool isAllDay;

  @Enumerated(EnumType.ordinal)
  late TaskPriority priority;

  late bool isAiMovable;
  late bool isSmartSchedule;

  late List<int> reminderOffsets;
  
  String? recurrenceRule;
  
  @Enumerated(EnumType.name)
  late TaskStatus status;

  late bool isSynced;

  // Convert to task object 
  Task toEntity() {
    return Task(
      id: originalId,
      type: type,
      category: category,
      tags: tags,
      title: title,
      description: description,
      location: location,
      startTime: startTime,
      endTime: endTime,
      deadline: deadline,
      duration: durationMinutes != null ? Duration(minutes: durationMinutes!) : null,
      isAllDay: isAllDay,
      priority: priority,
      isAiMovable: isAiMovable,
      isSmartSchedule: isSmartSchedule,
      reminderOffsets: reminderOffsets.map((micros) => Duration(microseconds: micros)).toList(),
      recurrenceRule: recurrenceRule,
      status: status, // Map status
      isSynced: isSynced,
    );
  }

  // convert from task object to database compatible fields
  static TaskModel fromEntity(Task task) {
    return TaskModel()
      ..originalId = task.id
      ..type = task.type
      ..category = task.category
      ..tags = task.tags
      ..title = task.title
      ..description = task.description
      ..location = task.location
      ..startTime = task.startTime
      ..endTime = task.endTime
      ..deadline = task.deadline
      ..durationMinutes = task.duration?.inMinutes
      ..isAllDay = task.isAllDay
      ..priority = task.priority
      ..isAiMovable = task.isAiMovable
      ..isSmartSchedule = task.isSmartSchedule
      ..reminderOffsets = task.reminderOffsets.map((d) => d.inMicroseconds).toList()
      ..recurrenceRule = task.recurrenceRule
      ..status = task.status // Map status
      ..isSynced = task.isSynced;
  }
}
