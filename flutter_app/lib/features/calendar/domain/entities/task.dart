import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'enums.dart';

const unset = Object();

// Equatable--useful for editing a task.
class Task extends Equatable {
  final String id;
  final TaskType type;
  final int? colorValue;
  final bool isAllDay;

  final String title; // change to a default name like task_1
  final String? description;
  final String? aiTip;

  final bool isSmartSchedule;
  final DateTime? startTime; //may be null if smart scheduled
  final DateTime? endTime; // may be null if smart scheduled
  final DateTime? deadline; // if none, will be defaulted to today

  final TaskPriority priority;
  final List<String> tags;
  final String? recurrenceRule; // using RRULE
  final String? location;

  // advanced
  final bool isAiMovable; // can be moved automatically by AI
  final bool isConflicting;
  final List<Duration> reminderOffsets;

  //flags
  final TaskStatus status;
  final bool isSynced;

  final String? googleEventId;

  const Task({
    required this.id,
    this.type = TaskType.task,
    this.colorValue,
    this.isAllDay = false,
    required this.title,
    this.description,
    this.aiTip,
    this.isSmartSchedule = false, // default: user schedules manually
    this.startTime,
    this.endTime,
    this.deadline,
    this.priority = TaskPriority.none,
    this.tags = const [],
    this.recurrenceRule,
    this.location,
    this.isAiMovable = true,
    this.isConflicting = true,
    this.status = TaskStatus.unscheduled,
    this.isSynced = false,
    this.reminderOffsets = const [],
    this.googleEventId,
  });

  factory Task.create({
    TaskType type = TaskType.task,
    int? colorValue,
    bool isAllDay = false,
    required String title,
    String? description,
    String? aiTip,
    bool isSmartSchedule = false,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? deadline,
    TaskPriority? priority,
    List<String> tags = const [],
    String? recurrenceRule,
    String? location,
    bool? isAiMovable,
    bool? isConflicting,
    TaskStatus status = TaskStatus.unscheduled,
    bool isSynced = false,
    List<Duration> reminderOffsets = const [],
  }) {
    return Task(
      id: const Uuid().v4(), // AUTOMATIC ID GENERATION
      type: type,
      colorValue: colorValue,
      isAllDay: isAllDay,
      title: title,
      description: description,
      aiTip: aiTip,
      isSmartSchedule: isSmartSchedule,
      startTime: startTime,
      endTime: endTime,
      deadline: deadline,
      priority: priority ?? TaskPriority.none,
      tags: tags,
      recurrenceRule: recurrenceRule,
      location: location,
      isAiMovable: isAiMovable ?? false,
      isConflicting: isConflicting ?? true,
      status: status,
      isSynced: false,
      reminderOffsets: reminderOffsets,
    );
  }
  Task copyWith({
    String? id,
    TaskType? type,
    int? colorValue,
    bool? isAllDay,
    String? title,
    String? description,
    String? aiTip,
    bool? isSmartSchedule,
    DateTime? startTime,
    DateTime? endTime,
    Object? deadline = unset,
    TaskPriority? priority,
    TaskCategory? category,
    List<String>? tags,
    Object? recurrenceRule = unset,
    String? location,
    bool? isAiMovable,
    bool? isConflicting,
    TaskStatus? status,
    bool? isSynced,
    List<Duration>? reminderOffsets,
    String? googleEventId,
  }) {
    return Task(
      id: id ?? this.id,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      isAllDay: isAllDay ?? this.isAllDay,
      title: title ?? this.title,
      description: description ?? this.description,
      aiTip: aiTip ?? this.aiTip,
      isSmartSchedule: isSmartSchedule ?? this.isSmartSchedule,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      deadline: deadline == unset ? this.deadline : deadline as DateTime?,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      recurrenceRule: recurrenceRule == unset
          ? this.recurrenceRule
          : recurrenceRule as String?,
      location: location ?? this.location,
      isAiMovable: isAiMovable ?? this.isAiMovable,
      isConflicting: isConflicting ?? this.isConflicting,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
      reminderOffsets: reminderOffsets ?? this.reminderOffsets,
      googleEventId: googleEventId ?? this.googleEventId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    colorValue,
    isAllDay,
    title,
    description,
    aiTip,
    isSmartSchedule,
    startTime,
    endTime,
    deadline,
    priority,
    tags,
    recurrenceRule,
    location,
    isAiMovable,
    isConflicting,
    status,
    isSynced,
    reminderOffsets,
    googleEventId,
  ];
}
