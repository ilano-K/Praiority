

import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/smart_features/data/models/smart_advice_request.dart';
import 'package:flutter_app/features/smart_features/services/smart_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final smartFeaturesControllerProvider = Provider((ref) => SmartFeaturesController(ref));

class SmartFeaturesController {
  final Ref _ref;

  SmartFeaturesController(this._ref);

  // smart schedule

  // smart organize

  // smart advice 
  Future<String?> executeSmartAdvice(String taskOriginalId, String? instruction) async {
    print("[DEBUG] THIS IS THE CLOUD ID: $taskOriginalId");
    try{
      final request = SmartAdviceRequest(
        taskOriginalId: taskOriginalId, 
        instruction: instruction
      );
      // response
      await _ref.read(smartServiceProvider).smartAdvice(request: request);

      // sync tasks
      await _ref.read(taskSyncServiceProvider).pullRemoteChanges();

      final task = await _ref.read(calendarRepositoryProvider).getTaskById(taskOriginalId);

      print(task?.aiTip);
      return task?.aiTip;
    } catch (e){
      print(e);
      rethrow;
    }
  }  

}