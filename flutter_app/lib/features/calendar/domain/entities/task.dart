import 'package:equatable/equatable.dart';
import 'enums.dart';

// Equatable--useful for editing a task. 
class Task extends Equatable{
  final String id;

  // Type and Category
  final TaskType type;
  final TaskCategory category;

  final String title; // change to a default name like task_1
  // optional fields
  final String? description;
  final String? location;

  // time
  final DateTime? startTime; //may be null if smart scheduled
  final DateTime? endTime; // may be null if smart scheduled
  final DateTime? deadline; // if none, will be defaulted to today
  final Duration? duration;

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
    this.category = TaskCategory.unassigned,
    this.description,
    this.location,
    this.startTime,
    this.endTime,
    this.deadline,
    this.duration,
    this.priority = TaskPriority.medium,
    this.isAiMovable = true,
    this.isSmartSchedule = false, // default: user schedules manually
    this.reminderOffsets = const [],
    this.recurrenceRule,
    this.status = TaskStatus.unscheduled,
    this.isSynced = false,
  });
  
  Task copyWith({
    String? id,
    TaskType? type,
    TaskCategory? category,
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? deadline,
    Duration? duration,
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
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      deadline: deadline ?? this.deadline,
      duration: duration ?? this.duration,
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
        title,
        description,
        location,
        startTime,
        endTime,
        deadline,
        duration,
        priority,
        isAiMovable,
        isSmartSchedule, // Add to props
        reminderOffsets,
        recurrenceRule,
        status,
        isSynced,
      ];
  
}



