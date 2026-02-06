class SmartScheduleRequest {
  final String taskOriginalId;
  final String targetDate;
  final String currentTime;
  final String? instruction;

  SmartScheduleRequest({
    required this.taskOriginalId,
    required this.targetDate,
    required this.currentTime,
    this.instruction,
  });

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskOriginalId,
      'target_date': targetDate,
      'current_time': currentTime,
      'instruction' : instruction ?? "",
    };
  }
}