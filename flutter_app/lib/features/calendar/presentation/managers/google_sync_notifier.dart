import 'dart:async';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoogleSyncNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> performSync() async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final syncService = ref.read(googleCalendarSyncServiceProvider);
      await syncService.syncGoogleData();
    });

    state = result;

    if (!state.hasError) {
      final calendarController = ref.read(calendarControllerProvider.notifier);
      await calendarController.refreshUi();
    }
  }
}
