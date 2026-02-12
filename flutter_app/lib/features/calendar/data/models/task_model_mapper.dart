// File: lib/features/calendar/data/models/task_model_mapper.dart

import 'package:flutter_app/features/calendar/data/models/task_model.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/presentation/utils/date_time_utils.dart'; // for dateOnly

// Extension ensures you can still call model.toCloudJsonFormat()
extension TaskModelMapper on TaskModel {
  Map<String, dynamic> toCloudJson() {
    return {
      "id": originalId,
      "type": type.name,
      "tags": tags,
      "title": title,
      "description": description,
      "ai_tip": aiTip,
      "location": location,
      "status": status.name,
      "color_value": colorValue,
      "start_time": startTime?.toUtc().toIso8601String(),
      "end_time": endTime?.toUtc().toIso8601String(),
      "deadline": deadline?.toUtc().toIso8601String(),
      "scheduled_date": startTime != null
          ? dateOnly(startTime!).toUtc().toIso8601String()
          : null,
      "is_all_day": isAllDay,
      "is_ai_movable": isAiMovable,
      "priority": priority.name,
      "recurrence_rule": recurrenceRule,
      "is_conflicting": isConflicting,
      "is_deleted": isDeleted,
      "reminder_minutes": reminderMinutes,
      "google_event_id": googleEventId,
    };
  }
}

// Static extension for "Factory-like" behavior
extension TaskModelFactory on TaskModel {
  static TaskModel fromCloudJson(Map<String, dynamic> json) {
    return TaskModel()
      ..originalId = json["id"]
      ..type = TaskType.values.byName(json["type"] as String)
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
          : []
      ..googleEventId = json["google_event_id"];
  }
}
