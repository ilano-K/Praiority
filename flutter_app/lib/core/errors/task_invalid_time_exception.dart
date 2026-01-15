class TaskInvalidTimeException implements Exception{
  final String message;
  TaskInvalidTimeException([this.message = "Invalid task start-time and end-time"]);

  @override
  String toString() => message;
}