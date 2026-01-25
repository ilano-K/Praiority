import 'package:flutter_app/features/settings/domain/entities/user_preferences.dart';

abstract class SettingsRepository {
  Future<UserPreferences?> getPreferences(String userId);
  Future<void> savePreferences(UserPreferences preferences);
}