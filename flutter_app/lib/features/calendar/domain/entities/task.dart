import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'enums.dart';

const unset = Object();
// Equatable--useful for editing a task. 
class Task extends Equatable{
  final String id;
  final TaskType type;
  final int? colorValue;
  final bool isAllDay;

  final String title; // change to a default name like task_1
  final String? description;

  final bool isSmartSchedule;
  final DateTime? startTime; //may be null if smart scheduled
  final DateTime? endTime; // may be null if smart scheduled
  final DateTime? deadline; // if none, will be defaulted to today
  
  final TaskPriority priority;
  final TaskCategory category;
  final List<String>tags;
  final String?recurrenceRule; // using RRULE
  final String? location;

  // advanced
  final bool isAiMovable; // can be moved automatically by AI
  final bool isConflicting;
 
  //flags
  final TaskStatus status;
  final bool isSynced; 

  const Task({
    required this.id,
    this.type = TaskType.task,
    this.colorValue,
    this.isAllDay = false,
    required this.title,
    this.description,
    this.isSmartSchedule = false, // default: user schedules manually
    this.startTime,
    this.endTime,
    this.deadline,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.none,
    this.tags = const [],
    this.recurrenceRule,
    this.location,
    this.isAiMovable = true,
    this.isConflicting = true ,
    this.status = TaskStatus.unscheduled,
    this.isSynced = false,
  });

  factory Task.create({
    TaskType type = TaskType.task,
    int? colorValue,
    bool isAllDay = false,
    required String title,
    String? description,
    bool isSmartSchedule = false,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? deadline,
    TaskPriority priority = TaskPriority.medium,
    TaskCategory category = TaskCategory.none,
    List<String> tags = const [],
    String? recurrenceRule,
    String? location,
    bool? isAiMovable,
    bool? isConflicting,
    TaskStatus status = TaskStatus.unscheduled,
    bool isSynced = false
  }) {
    return Task(
      id: const Uuid().v4(), // AUTOMATIC ID GENERATION
      type: type,
      colorValue: colorValue,
      isAllDay: isAllDay,
      title: title,
      description: description,
      isSmartSchedule: isSmartSchedule,
      startTime: startTime,
      endTime: endTime,
      deadline: deadline,
      priority: priority,
      category: category,
      tags: tags,
      recurrenceRule: recurrenceRule,
      location: location,
      isAiMovable: isAiMovable ?? false,
      isConflicting: isConflicting ?? true,
      status: status,
      isSynced: false,
    );
  }
  Task copyWith({
    String? id,
    TaskType? type,
    int? colorValue,
    bool? isAllDay,
    String? title,
    String? description,
    bool? isSmartSchedule,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? deadline,
    TaskPriority? priority,
    TaskCategory? category,
    List<String>? tags,
    Object? recurrenceRule = unset,
    String? location,
    bool? isAiMovable,
    bool? isConflicting, 
    TaskStatus? status,
    bool? isSynced,
  }){
    return Task(
      id: id ?? this.id,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      isAllDay: isAllDay ?? this.isAllDay,
      title: title ?? this.title,
      description: description ?? this.description,
      isSmartSchedule: isSmartSchedule ?? this.isSmartSchedule,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      recurrenceRule: recurrenceRule == unset
        ? this.recurrenceRule
        : recurrenceRule as String?, 
      location: location ?? this.location,
      isAiMovable: isAiMovable ?? this.isAiMovable,
      isConflicting: isConflicting ?? this.isConflicting,
      status: status ?? this.status,
      isSynced: isSynced ?? this.isSynced,
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
        isSmartSchedule,
        startTime,
        endTime,
        deadline,
        priority,
        category,
        tags,
        recurrenceRule,
        location,
        isAiMovable,
        isConflicting,
        status,
        isSynced,
      ];
  
}

