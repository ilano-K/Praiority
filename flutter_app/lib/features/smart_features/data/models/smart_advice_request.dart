class SmartAdviceRequest {
  final String cloudId;
  final String? instruction;

  SmartAdviceRequest({
    required this.cloudId,
    this.instruction,
  });

  Map<String, dynamic> toJson(){
    return{
      'task_id': cloudId,
      'instruction': instruction ?? '',
    };
  }
}