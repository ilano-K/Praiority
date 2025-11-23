import 'package:equatable/equatable.dart';

// Enums for typing
enum TaskType {task, event}
enum TaskCategory {focus, light, active, unassigned}
enum TaskPriority {low, medium, high}

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
  final DateTime? start_time; //may be null if smart scheduled
  final DateTime? end_time; // may be null if smart scheduled
  final DateTime? deadline; // if none, will be defaulted to today
  final DateTime? duration;

  //priority
  final TaskPriority priority;

  // Ai shit
  final bool isAiMovable; // can be moved automatically by AI
  final bool isSmartSchedule;

  // Reminders
  final List<Duration> reminderOffsets; // (e.g., 1 hour before, 30 mins before, 10 mins before)

  // Recurrence
  final String?recurrenceRule; // using RRULE

  final bool isCompleted;
  final bool isSynced; 
  
  
}



