import 'package:flutter_app/features/calendar/data/models/task_tags_model.dart';
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

  final tags =  IsarLinks<TaskTagsModel>();

  late String title;

  String? description;
  String? location;
  late int colorValue;

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
    final tagEntity = tags.isNotEmpty
      ? tags.first.toEntity()
      : null;

    return Task(
      id: originalId,
      type: type,
      category: category,
      tags: tagEntity,
      title: title,
      description: description,
      location: location,
      colorValue: colorValue,
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
      ..title = task.title
      ..description = task.description
      ..location = task.location
      ..colorValue = task.colorValue
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
