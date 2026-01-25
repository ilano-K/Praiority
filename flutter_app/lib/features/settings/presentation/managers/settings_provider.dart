import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:flutter_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flutter_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  final db = ref.watch(localStorageServiceProvider); 
  return SettingsLocalDataSourceImpl(db);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
});