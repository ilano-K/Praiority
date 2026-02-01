import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:flutter_app/features/settings/data/repositories/settings_repository.dart';
import 'package:flutter_app/features/settings/services/user_pref_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  final db = ref.watch(localStorageServiceProvider); 
  return SettingsLocalDataSource(db.isar);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepository(dataSource);
});

final userPrefSyncServiceProvider = Provider<UserPrefSyncService>((ref) {
  final localDb = ref.watch(settingsLocalDataSourceProvider);
  final supabase = Supabase.instance.client;
  return UserPrefSyncService(supabase, localDb);
});