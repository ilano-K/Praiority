class TaskConflictException implements Exception{
  final String message;
  TaskConflictException([this.message = 'Task conflicts with another task']);

  @override 
  String toString() => message;
}