
import 'package:flutter_app/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:flutter_app/features/settings/data/models/user_preferences_model.dart';
import 'package:flutter_app/features/settings/domain/entities/user_preferences.dart';

class SettingsRepository{
  final SettingsLocalDataSource settingsLocalDataSource;

  SettingsRepository(this.settingsLocalDataSource);

  Future<UserPreferences> getPreferences() async {
    final model = await settingsLocalDataSource.getPreferences();
    return model.toDomain();
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    await settingsLocalDataSource.savePreferences(preferences.toModel());
  }

  Future<void> deleteUserPreferences() async {
    await settingsLocalDataSource.deleteUserPreferences();
  }
}