class SmartScheduleRequest {
  final String cloudId;
  final DateTime targetDate;
  final DateTime currentTime;
  final String? instruction;

  SmartScheduleRequest({
    required this.cloudId,
    required this.targetDate,
    required this.currentTime,
    this.instruction,
  });

  Map<String, dynamic> toJson() {
    return {
      'task_id': cloudId,
      'target_date': targetDate.toUtc().toIso8601String(),
      'current_time': currentTime.toUtc().toIso8601String(),
      'instruction' : instruction ?? "",
    };
  }
}