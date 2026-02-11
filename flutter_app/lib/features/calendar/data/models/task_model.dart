import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/presentation/utils/date_time_utils.dart';

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
  String? aiTip;
  String? location;
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

  // Convert to task object
  Task toEntity() {
    return Task(
      id: originalId,
      type: type,
      category: category,
      tags: tags,
      title: title,
      description: description,
      aiTip: aiTip,
      location: location,
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
    );
  }

  Map<String, dynamic> toCloudJsonFormat() {
    return {
      "id": originalId,
      "type": type.name,
      "tags": tags,
      "title": title,
      "description": description,
      "ai_tip": aiTip,
      "location": location,
      "category": category.name,
      "status": status.name,
      "color_value": colorValue,
      "start_time": startTime?.toUtc().toIso8601String(),
      "end_time": endTime?.toUtc().toIso8601String(),
      "deadline": deadline?.toUtc().toIso8601String(),
      "scheduled_date": startTime != null
          ? dateOnly(startTime!)
                .toUtc()
                .toIso8601String() // null-safe
          : null,
      "is_all_day": isAllDay,
      "is_ai_movable": isAiMovable,
      "priority": priority.name,
      "recurrence_rule": recurrenceRule,
      "is_conflicting": isConflicting,
      "is_deleted": isDeleted,
      "reminder_minutes": reminderMinutes,
    };
  }

  static TaskModel fromCloudJson(Map<String, dynamic> json) {
    return TaskModel()
      ..originalId = json["id"]
      ..type = TaskType.values.byName(json["type"] as String)
      ..category = TaskCategory.values.byName(json["category"] as String)
      ..tags = json["tags"] != null ? List<String>.from(json["tags"]) : []
      ..title = json["title"] as String
      ..description = json["description"] as String?
      ..aiTip = json["ai_tip"] as String?
      ..location = json["location"] as String?
      ..colorValue = json["color_value"] as int?
      ..startTime = json["start_time"] != null
          ? DateTime.parse(json["start_time"] as String).toLocal()
          : null
      ..endTime = json["end_time"] != null
          ? DateTime.parse(json["end_time"] as String).toLocal()
          : null
      ..deadline = json["deadline"] != null
          ? DateTime.parse(json["deadline"] as String).toLocal()
          : null
      ..isAllDay = json["is_all_day"] as bool? ?? false
      ..priority = TaskPriority.values.byName(json["priority"] as String)
      ..isAiMovable = json["is_ai_movable"] as bool? ?? false
      ..recurrenceRule = json["recurrence_rule"] as String?
      ..status = TaskStatus.values.byName(json["status"] as String)
      ..isConflicting = json["is_conflicting"] as bool? ?? false
      ..isDeleted = json["is_deleted"] as bool? ?? false
      ..reminderMinutes = json["reminder_minutes"] != null
          ? List<int>.from(json["reminder_minutes"])
          : [];
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
      ..reminderMinutes = task.reminderOffsets.map((d) => d.inMinutes).toList();
  }
}
