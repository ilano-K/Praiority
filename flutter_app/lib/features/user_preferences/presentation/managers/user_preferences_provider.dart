import 'package:flutter_app/core/providers/global_providers.dart';
import 'package:flutter_app/features/user_preferences/data/datasources/settings_local_data_source.dart';
import 'package:flutter_app/features/user_preferences/data/repositories/settings_repository.dart';
import 'package:flutter_app/features/user_preferences/domain/entities/user_preferences.dart';
import 'package:flutter_app/features/user_preferences/presentation/managers/user_preferences_notifier.dart';
import 'package:flutter_app/features/user_preferences/services/user_pref_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((
  ref,
) {
  final db = ref.watch(localStorageServiceProvider);
  return SettingsLocalDataSource(db.isar);
});

final userPreferencesRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepository(dataSource);
});

final userPreferencesControllerProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences?>(() {
      return UserPreferencesNotifier();
    });

final userPrefSyncServiceProvider = Provider<UserPrefSyncService>((ref) {
  final localDb = ref.watch(settingsLocalDataSourceProvider);
  final supabase = Supabase.instance.client;
  return UserPrefSyncService(supabase, localDb);
});
