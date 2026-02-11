import 'package:flutter_app/features/settings/data/models/user_preferences_model.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

class SettingsLocalDataSource {
  final Isar isar;

  SettingsLocalDataSource(this.isar);

  Future<UserPreferencesModel?> getPreferences() async {
    final existing = await isar.userPreferencesModels.where().findFirst();
    return existing;
  }

  Future<void> savePreferences(UserPreferencesModel model) async {
    await isar.writeTxn(() async {
      final existing = await isar.userPreferencesModels
          .filter()
          .idEqualTo(model.id)
          .findFirst();

      if (existing != null) {
        model.id = existing.id;
      }
      await isar.userPreferencesModels.put(model);
    });
  }

  Future<void> markPrefAsSynced(int id) async {
    await isar.writeTxn(() async {
      final existing = await isar.userPreferencesModels
          .filter()
          .idEqualTo(id)
          .findFirst();

      if (existing == null) {
        return;
      }
      // set as synced
      existing.isSynced = true;
      await isar.userPreferencesModels.put(existing);
    });
  }

  Future<void> updateUserPreferenceFromCloud(UserPreferencesModel model) async {
    await isar.writeTxn(() async {
      final existing = await isar.userPreferencesModels
          .filter()
          .cloudIdEqualTo(model.cloudId)
          .findFirst();

      // if there's an existing data, match the id
      if (existing != null) {
        model.id = existing.id;
      }

      // marked as synced
      model.isSynced = true;
      model.isSetupComplete = true;

      // save to isar
      await isar.userPreferencesModels.put(model);
    });
  }

  Future<void> deleteUserPreferences() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}
