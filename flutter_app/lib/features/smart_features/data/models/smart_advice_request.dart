class SmartAdviceRequest {
  final String taskOriginalId;
  final String? instruction;

  SmartAdviceRequest({
    required this.taskOriginalId,
    required this.instruction,
  });

  Map<String, dynamic> toJson(){
    return{
      'task_id': taskOriginalId,
      'instruction': instruction ?? '',
    };
  }
}