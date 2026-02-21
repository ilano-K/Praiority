import 'dart:async';
import 'package:flutter_app/core/providers/global_providers.dart';
import 'package:flutter_app/core/theme/theme_notifier.dart';
import 'package:flutter_app/features/auth/data/auth_provider.dart';
import 'package:flutter_app/features/auth/data/auth_service.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/user_preferences/presentation/managers/user_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    //
  }
  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.signUp(email, password);
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.signIn(email, password);
    });
  }

  Future<void> signOut() async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      final taskSyncService = ref.read(taskSyncServiceProvider);
      final userPrefsSyncService = ref.read(userPrefSyncServiceProvider);

      // Push local changes while session is still active
      await taskSyncService.pushLocalChanges();
      await userPrefsSyncService.pushLocalChanges();

      // Sign out from the auth provider first to ensure the session is
      // cleared before we clear local state. This prevents the app from
      // briefly seeing a valid session with missing preferences (which
      // shows `WorkHours`).
      await authService.signOut();

      // Now clear local state and invalidate providers
      await _resetAppState();
    });
  }

  Future<void> signInWithGoogle() async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
    });
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.sendPasswordResetEmail(email);
    });
  }

  Future<void> updatePassword(String newPassword) async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      await authService.updatePassword(newPassword);
    });
  }

  Future<void> _resetAppState() async {
    // Invalidate controllers, repositories and data sources so no state
    // remains in memory after sign-out.
    final dbProvider = ref.read(localStorageServiceProvider);

    await dbProvider.clearDatabase();
    ref.invalidate(calendarControllerProvider);
    ref.invalidate(tagsProvider);
    ref.invalidate(calendarRepositoryProvider);
    ref.invalidate(calendarDataSourceProvider);
    ref.invalidate(googleSyncNotifierProvider);
    ref.invalidate(googleCalendarSyncServiceProvider);
    ref.invalidate(googleCalendarRemoteDataSourceProvider);
    ref.invalidate(taskSyncServiceProvider);

    ref.invalidate(userPreferencesControllerProvider);
    ref.invalidate(userPreferencesRepositoryProvider);
    ref.invalidate(settingsLocalDataSourceProvider);
    ref.invalidate(userPrefSyncServiceProvider);

    ref.read(themeProvider.notifier).resetToDefault();
  }
}
