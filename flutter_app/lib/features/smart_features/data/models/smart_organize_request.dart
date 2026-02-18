class SmartOrganizeRequest {
  final DateTime targetStart;
  final DateTime targetEnd;
  final DateTime currentTime;
  final String? instruction;

  SmartOrganizeRequest({
    required this.targetStart,
    required this.targetEnd,
    required this.currentTime,
    this.instruction,
  });

  Map<String, dynamic> toJson() {
    return {
      'target_start': targetStart.toUtc().toIso8601String(),
      'target_end': targetEnd.toUtc().toIso8601String(),
      'current_time': currentTime.toUtc().toIso8601String(),
      'instruction': instruction ?? "",
    };
  }
}
