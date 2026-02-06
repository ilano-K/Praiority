class SmartOrganizeRequest {
  final String targetDate;
  final String currentTime;
  final String? instruction;

  SmartOrganizeRequest({
    required this.targetDate,
    required this.currentTime,
    this.instruction,
  });

  Map<String, dynamic> toJson() {
    return {
      'target_date': targetDate,
      'current_time': currentTime,
      'instruction' : instruction ?? "",
    };
  }
}