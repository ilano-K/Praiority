import 'package:flutter_app/features/user_preferences/domain/entities/user_preferences.dart';
import 'package:flutter_app/features/user_preferences/presentation/managers/user_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class UserPreferencesNotifier extends AsyncNotifier<UserPreferences?> {
  @override
  FutureOr<UserPreferences?> build() async {
    return await loadUserSettings();
  }

  Future<UserPreferences?> loadUserSettings() async {
    final repository = ref.read(userPreferencesRepositoryProvider);
    return await repository.getPreferences();
  }

  Future<void> saveSettings({String? start, String? end, bool? isDark}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userPreferencesRepositoryProvider);
      final currentPref = state.value;
      UserPreferences newPrefs;

      if (currentPref == null) {
        newPrefs = UserPreferences.create(start!, end!);
        await repository.savePreferences(newPrefs);
      } else {
        newPrefs = currentPref.copyWith(
          startWorkHours: start,
          endWorkHours: end,
          isDarkMode: isDark,
        );
        await repository.savePreferences(newPrefs);
      }

      final prefSyncController = ref.read(userPrefSyncServiceProvider);
      // save to database asynchronously
      unawaited(prefSyncController.pushLocalChanges());
      return newPrefs;
    });
  }
}
