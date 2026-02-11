import 'package:flutter_app/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_app/features/settings/presentation/managers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, UserPreferences?>(() {
      return SettingsController();
    });

class SettingsController extends AsyncNotifier<UserPreferences?> {
  @override
  FutureOr<UserPreferences?> build() async {
    return await loadUserSettings();
  }

  Future<UserPreferences?> loadUserSettings() async {
    final repository = ref.watch(settingsRepositoryProvider);
    return await repository.getPreferences();
  }

  Future<void> saveSettings(String start, String end) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Safely load existing preferences
      final currentPrefs = await loadUserSettings();

      final newPrefs = (currentPrefs ?? UserPreferences()).copyWith(
        startWorkHours: start,
        endWorkHours: end,
      );

      final repository = ref.watch(settingsRepositoryProvider);
      await repository.savePreferences(newPrefs);

      final prefSyncController = ref.read(userPrefSyncServiceProvider);
      // save to database asynchronously
      unawaited(prefSyncController.pushLocalChanges());

      return newPrefs;
    });
  }
}
