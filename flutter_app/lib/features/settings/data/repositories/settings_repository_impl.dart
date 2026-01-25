
import 'package:flutter_app/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:flutter_app/features/settings/data/models/user_preferences_model.dart';
import 'package:flutter_app/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository{
  final SettingsLocalDataSource settingsLocalDataSource;

  SettingsRepositoryImpl(this.settingsLocalDataSource);

  @override  
  Future<UserPreferences?> getPreferences(String userId) async {
    final model = await settingsLocalDataSource.getPreferences(userId);
    return model?.toEntity();
  }

  @override  
  Future<void> savePreferences(UserPreferences preferences) async {
    final model = UserPreferencesModel.fromEntity(preferences);
    await settingsLocalDataSource.savePreferences(model);
  }
}