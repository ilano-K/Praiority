import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/task_tags.dart';
import 'package:uuid/uuid.dart';
import 'enums.dart';

// Equatable--useful for editing a task. 
class Task extends Equatable{
  final String id;

  // Type and Category
  final TaskType type;
  final TaskCategory category;
  final TaskTags? tags;

  final String title; // change to a default name like task_1
  // optional fields
  final String? description;
  final String? location;
  final Color? color;

  // time
  final DateTime? startTime; //may be null if smart scheduled
  final DateTime? endTime; // may be null if smart scheduled
  final DateTime? deadline; // if none, will be defaulted to today
  final Duration? duration;
  final bool isAllDay;
  //priority
  final TaskPriority priority;

  // Ai shit
  final bool isAiMovable; // can be moved automatically by AI
  final bool isSmartSchedule;

  // Reminders
  final List<Duration> reminderOffsets; // (e.g., 1 hour before, 30 mins before, 10 mins before)

  // Recurrence
  final String?recurrenceRule; // using RRULE

  final TaskStatus status;
  final bool isSynced; 

  const Task({
    required this.id,
    required this.title,
    this.type = TaskType.task,
    this.category = TaskCategory.none,
    this.tags,
    this.description,
    this.location,
    this.color,
    this.startTime,
    this.endTime,
    this.deadline,
    this.duration,
    this.isAllDay = false,
    this.priority = TaskPriority.medium,
    this.isAiMovable = true,
    this.isSmartSchedule = false, // default: user schedules manually
    this.reminderOffsets = const [],
    this.recurrenceRule,
    this.status = TaskStatus.unscheduled,
    this.isSynced = false,
  });

  factory Task.create({
    required String title,
    TaskType type = TaskType.task,
    TaskCategory category = TaskCategory.none,
    TaskTags? tags,
    String? description,
    String? location,
    Color? color,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? deadline,
    Duration? duration,
    bool isAllDay = false,
    TaskPriority priority = TaskPriority.medium,
    bool isAiMovable = true,
    bool isSmartSchedule = false,
    List<Duration> reminderOffsets = const [],
    String? recurrenceRule,
    TaskStatus status = TaskStatus.unscheduled,
  }) {
    return Task(
      id: const Uuid().v4(), // AUTOMATIC ID GENERATION
      title: title,
      type: type,
      category: category,
      tags: tags,
      description: description,
      location: location,
      color: color,
      startTime: startTime,
      endTime: endTime,
      deadline: deadline,
      duration: duration,
      isAllDay: isAllDay,
      priority: priority,
      isAiMovable: isAiMovable,
      isSmartSchedule: isSmartSchedule,
      reminderOffsets: reminderOffsets,
      recurrenceRule: recurrenceRule,
      status: status,
      isSynced: false,
    );
  }
  Task copyWith({
    String? id,
    TaskType? type,
    TaskCategory? category,
    TaskTags? tags,
    String? title,
    String? description,
    String? location,
    Color? color,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? deadline,
    Duration? duration,
    bool? isAllDay,
    TaskPriority? priority,
    bool? isAiMovable,
    bool? isSmartSchedule, // Add to copyWith
    List<Duration>? reminderOffsets,
    String? recurrenceRule,
    TaskStatus? status,
    bool? isSynced,
  }){
    return Task(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      color: color ?? this.color,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      deadline: deadline ?? this.deadline,
      duration: duration ?? this.duration,
      isAllDay: isAllDay ?? this.isAllDay,
      priority: priority ?? this.priority,
      isAiMovable: isAiMovable ?? this.isAiMovable,
      isSmartSchedule: isSmartSchedule ?? this.isSmartSchedule,
      reminderOffsets: reminderOffsets ?? this.reminderOffsets,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        category,
        tags,
        title,
        description,
        location,
        color,
        startTime,
        endTime,
        deadline,
        duration,
        isAllDay,
        priority,
        isAiMovable,
        isSmartSchedule, // Add to props
        reminderOffsets,
        recurrenceRule,
        status,
        isSynced,
      ];
  
}

