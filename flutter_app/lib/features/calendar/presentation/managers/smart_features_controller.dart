import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/smart_features/data/models/smart_advice_request.dart';
import 'package:flutter_app/features/smart_features/data/models/smart_generate_request.dart';
import 'package:flutter_app/features/smart_features/data/models/smart_organize_request.dart';
import 'package:flutter_app/features/smart_features/data/models/smart_schedule_request.dart';
import 'package:flutter_app/features/smart_features/services/smart_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final smartFeaturesControllerProvider = Provider(
  (ref) => SmartFeaturesController(ref),
);

class SmartFeaturesController {
  final Ref _ref;

  SmartFeaturesController(this._ref);

  // smart schedule
  Future<void> executeSmartSchedule(
    String cloudId,
    DateTime targetDate,
    DateTime currentTime, {
    String? instruction,
  }) async {
    print(
      "[DEBUG] Executing request: Smart Schedule for task with cloudId: $cloudId",
    );

    final range = targetDate.range(CalendarScope.day);
    try {
      final request = SmartScheduleRequest(
        cloudId: cloudId,
        targetStart: range.start,
        targetEnd: range.end,
        currentTime: currentTime,
        instruction: instruction,
      );

      await _ref.read(smartServiceProvider).smartSchedule(request: request);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> executeSmartGenerate(
    DateTime targetDate,
    DateTime currentTime, {
    String? instruction,
  }) async {
    print("[DEBUG] Executing request: Smart Generate Task");
    try {
      final dateRange = targetDate.range(CalendarScope.day);

      final request = SmartGenerateRequest(
        targetStart: dateRange.start,
        targetEnd: dateRange.end,
        currentTime: currentTime,
        instruction: instruction,
      );

      print(
        "[DEBUG] Executing request:heres the request: START ${request.targetStart}, END ${request.targetEnd} INST ${request.instruction} CURRTIME ${request.currentTime}",
      );

      await _ref.read(smartServiceProvider).smartGenerateTask(request: request);
    } catch (e) {
      rethrow;
    }
  }

  // smart organize
  Future<void> executeSmartOrganize(
    DateTime targetDate,
    DateTime currentTime, {
    String? instruction,
  }) async {
    print(
      "[DEBUG] Executing request: Smart Organize for target date: $targetDate",
    );

    final range = targetDate.range(CalendarScope.day);
    try {
      final request = SmartOrganizeRequest(
        targetStart: range.start,
        targetEnd: range.end,
        currentTime: currentTime,
        instruction: instruction,
      );

      print(
        "[DEBUG] SMART CONTROLLER: this is the user instruction: ${request.instruction}",
      );

      await _ref.read(smartServiceProvider).smartOrganize(request: request);
    } catch (e) {
      rethrow;
    }
  }

  // smart advice
  Future<String?> executeSmartAdvice(
    String cloudId, {
    String? instruction,
  }) async {
    print(
      "[DEBUG] Executing request: Smart Advice for task with cloudId: $cloudId",
    );
    try {
      final request = SmartAdviceRequest(
        cloudId: cloudId,
        instruction: instruction,
      );
      // response
      await _ref.read(smartServiceProvider).smartAdvice(request: request);

      // sync tasks

      final task = await _ref
          .read(calendarRepositoryProvider)
          .getTaskById(cloudId);

      return task?.aiTip;
    } catch (e) {
      rethrow;
    }
  }
}
