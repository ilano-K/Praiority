class SmartScheduleRequest {
  final String cloudId;
  final DateTime targetStart;
  final DateTime targetEnd;
  final DateTime currentTime;
  final String? instruction;

  SmartScheduleRequest({
    required this.cloudId,
    required this.targetStart,
    required this.targetEnd,
    required this.currentTime,
    this.instruction,
  });

  Map<String, dynamic> toJson() {
    return {
      'task_id': cloudId,
      'target_start': targetStart.toUtc().toIso8601String(),
      'target_end': targetEnd.toUtc().toIso8601String(),
      'current_time': currentTime.toUtc().toIso8601String(),
      'instruction': instruction ?? "",
    };
  }
}
