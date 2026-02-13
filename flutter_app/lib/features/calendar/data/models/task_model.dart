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

  late List<String> tags;

  late String title;

  String? description;
  String? aiTip;
  int? colorValue;

  DateTime? startTime;
  DateTime? endTime;
  DateTime? deadline;
  int? durationMinutes;

  late bool isAllDay;

  @Enumerated(EnumType.name)
  late TaskPriority priority;

  late bool isAiMovable;

  String? recurrenceRule;

  @Enumerated(EnumType.name)
  late TaskStatus status;

  // syncing logic
  @Index()
  bool isDeleted = false;
  @Index()
  bool isSynced = false;
  DateTime? updatedAt;

  late bool isConflicting;
  late List<int>? reminderMinutes;

  String? googleEventId;

  // Convert to task object
  Task toEntity() {
    return Task(
      id: originalId,
      type: type,
      tags: tags,
      title: title,
      description: description,
      aiTip: aiTip,
      colorValue: colorValue,
      startTime: startTime,
      endTime: endTime,
      deadline: deadline,
      isAllDay: isAllDay,
      priority: priority,
      isAiMovable: isAiMovable,
      recurrenceRule: recurrenceRule,
      status: status, // Map status
      isSynced: isSynced,
      isConflicting: isConflicting,
      reminderOffsets:
          reminderMinutes?.map((m) => Duration(minutes: m)).toList() ?? [],
      googleEventId: googleEventId,
    );
  }

  // convert from task object to database compatible fields
  static TaskModel fromEntity(Task task) {
    return TaskModel()
      ..originalId = task.id
      ..type = task.type
      ..tags = task.tags
      ..title = task.title
      ..description = task.description
      ..colorValue = task.colorValue
      ..startTime = task.startTime
      ..endTime = task.endTime
      ..deadline = task.deadline
      ..isAllDay = task.isAllDay
      ..priority = task.priority
      ..isAiMovable = task.isAiMovable
      ..recurrenceRule = task.recurrenceRule
      ..status = task
          .status // Map status
      ..isSynced = task.isSynced
      ..isConflicting = task.isConflicting
      ..reminderMinutes = task.reminderOffsets.map((d) => d.inMinutes).toList()
      ..googleEventId = task.googleEventId;
  }
}
