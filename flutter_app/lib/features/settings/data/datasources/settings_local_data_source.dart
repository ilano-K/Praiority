
import 'package:flutter_app/core/services/local_database_service.dart';
import 'package:flutter_app/features/settings/data/models/user_preferences_model.dart';
import 'package:isar/isar.dart';

abstract class SettingsLocalDataSource {
  Future<UserPreferencesModel?> getPreferences(String userId);
  Future<void> savePreferences(UserPreferencesModel model);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final LocalDatabaseService db;

  SettingsLocalDataSourceImpl(this.db);

  @override   
  Future<UserPreferencesModel?> getPreferences(String userId) async {
    return await db.isar.userPreferencesModels.filter().userIdEqualTo(userId).findFirst();
  }

  @override  
  Future<void> savePreferences(UserPreferencesModel model) async {
    await db.isar.writeTxn(() async {
      final existing = await db.isar.userPreferencesModels
          .filter()
          .userIdEqualTo(model.userId)
          .findFirst();

      if (existing != null) {
        model.id = existing.id;
      }
      await db.isar.userPreferencesModels.put(model);
    });
  }
}