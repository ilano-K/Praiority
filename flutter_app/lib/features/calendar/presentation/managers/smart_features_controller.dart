

import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/smart_features/data/models/smart_advice_request.dart';
import 'package:flutter_app/features/smart_features/data/models/smart_organize_request.dart';
import 'package:flutter_app/features/smart_features/data/models/smart_schedule_request.dart';
import 'package:flutter_app/features/smart_features/services/smart_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final smartFeaturesControllerProvider = Provider((ref) => SmartFeaturesController(ref));

class SmartFeaturesController {
  final Ref _ref;

  SmartFeaturesController(this._ref);

  // smart schedule
  Future<void> executeSmartSchedule(String cloudId, DateTime targetDate, DateTime currentTime, {String? instruction}) async {
    print("[DEBUG] Executing request: Smart Advice for task with cloudId: $cloudId");
    try{
      final request = SmartScheduleRequest(
        cloudId: cloudId, 
        targetDate: targetDate, 
        currentTime: currentTime
      );

      await _ref.read(smartServiceProvider).smartSchedule(request: request);
      await _ref.read(taskSyncServiceProvider).pullRemoteChanges();
    } catch(e){
      print(e);
      rethrow;
    }
  }

  // smart organize
  Future<void> executeSmartOrganize(DateTime targetDate, DateTime currentTime, {String? instruction}) async {
    print("[DEBUG] Executing request: Smart Organize for target date: $targetDate");
    try{
      final request = SmartOrganizeRequest(
        targetDate: targetDate, 
        currentTime: currentTime
      );

      await _ref.read(smartServiceProvider).smartOrganize(request: request);
      await _ref.read(taskSyncServiceProvider).pullRemoteChanges();
    } catch(e){
      print(e);
      rethrow; 
    }
  }
  // smart advice 
  Future<String?> executeSmartAdvice(String cloudId, {String? instruction}) async {
    print("[DEBUG] Executing request: Smart Advice for task with cloudId: $cloudId");
    try{
      final request = SmartAdviceRequest(
        cloudId: cloudId, 
        instruction: instruction
      );
      // response
      await _ref.read(smartServiceProvider).smartAdvice(request: request);

      // sync tasks
      await _ref.read(taskSyncServiceProvider).pullRemoteChanges();

      final task = await _ref.read(calendarRepositoryProvider).getTaskById(cloudId);

      return task?.aiTip;
    } catch (e){
      print(e);
      rethrow;
    }
  }  

}