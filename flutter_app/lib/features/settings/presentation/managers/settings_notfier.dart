import 'package:flutter_app/core/providers/auth_providers.dart';
import 'package:flutter_app/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_app/features/settings/presentation/managers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

final settingsControllerProvider = 
    AsyncNotifierProvider<SettingsController, UserPreferences?>(() {
  return SettingsController();
});

class SettingsController extends AsyncNotifier<UserPreferences?>{

  @override  
  FutureOr<UserPreferences?> build() async {
    // get user id here
    final userId = ref.watch(currentUserIdProvider);
    if(userId == null) return null;

    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getPreferences(userId);
  }

  Future<void> saveSettings(String start, String end) async {
    final userId = ref.read(currentUserIdProvider);
    if(userId == null) return;

    state = const AsyncLoading();

    final newPrefs = UserPreferences(
      id: userId,
      startWorkHours: start,
      endWorkHours: end,
      isSetupComplete: true,
    );

    state = await AsyncValue.guard(() async {
      await ref.read(settingsRepositoryProvider).savePreferences(newPrefs);
      return newPrefs;
    });
  }
}