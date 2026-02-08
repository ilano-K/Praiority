enum TaskType { task, event, birthday }
enum TaskCategory { easy, average, hard, none }
enum TaskPriority { none, low, medium, high }
enum TaskStatus { unscheduled, scheduled, completed, pending }

/// Converts a string to TaskType. Returns null if not valid.
TaskType? taskTypeFromString(String value) {
  switch (value.toLowerCase()) {
    case 'task':
      return TaskType.task;
    case 'event':
      return TaskType.event;
    case 'birthday':
      return TaskType.birthday;
    default:
      return null;
  }
}

/// Converts a string to TaskCategory. Returns null if not valid.
TaskCategory? taskCategoryFromString(String value) {
  switch (value.toLowerCase()) {
    case 'easy':
      return TaskCategory.easy;
    case 'average':
      return TaskCategory.average;
    case 'hard':
      return TaskCategory.hard;
    default:
      return null;
  }
}

/// Converts a string to TaskPriority. Returns null if not valid.
TaskPriority? taskPriorityFromString(String value) {
  switch (value.toLowerCase()) {
    case 'low':
      return TaskPriority.low;
    case 'medium':
      return TaskPriority.medium;
    case 'high':
      return TaskPriority.high;
    default:
      return null;
  }
}

/// Converts a string to TaskStatus. Returns null if not valid.
TaskStatus? taskStatusFromString(String value) {
  switch (value.toLowerCase()) {
    case 'unscheduled':
      return TaskStatus.unscheduled;
    case 'scheduled':
      return TaskStatus.scheduled;
    case 'completed':
      return TaskStatus.completed;
    case 'pending':
      return TaskStatus.pending;
    default:
      return null;
  }
}
