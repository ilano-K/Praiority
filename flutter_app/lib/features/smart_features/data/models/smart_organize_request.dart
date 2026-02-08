class SmartOrganizeRequest {
  final DateTime targetDate;
  final DateTime currentTime;
  final String? instruction;

  SmartOrganizeRequest({
    required this.targetDate,
    required this.currentTime,
    this.instruction,
  });

  Map<String, dynamic> toJson() {
    return {
      'target_date': targetDate.toUtc().toIso8601String(),
      'current_time': currentTime.toUtc().toIso8601String(),
      'instruction' : instruction ?? "",
    };
  }
}