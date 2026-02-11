import 'package:flutter/cupertino.dart';
import 'package:flutter_app/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:flutter_app/features/settings/data/models/user_preferences_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPrefSyncService {
  final SupabaseClient _supabase;
  final SettingsLocalDataSource _localDb;

  UserPrefSyncService(this._supabase, this._localDb);

  Future<void> syncPreferences() async {
    if (_supabase.auth.currentUser == null) return;
    await pushLocalChanges();
    await pullRemoteChanges();
  }

  Future<void> pushLocalChanges() async {
    debugPrint("[DEBUG] PUSHING USER SETTINGS LOCAL CHANGES NOW!");
    // get user preferences.
    final userPrefsModel = await _localDb.getPreferences();

    debugPrint("[DEBUG] MODEL: $userPrefsModel");

    if (userPrefsModel == null) return;
    // if null or already synced, return
    if (userPrefsModel.isSynced == true) return;

    try {
      // convert model to json
      final userPrefsMap = userPrefsModel.toJson();
      // get user id
      final userId = _supabase.auth.currentUser!.id;

      userPrefsMap["user_id"] = userId;
      // request for update
      await _supabase.from('user_preferences').upsert(userPrefsMap);

      await _localDb.markPrefAsSynced(userPrefsModel.id);
    } catch (e) {
      debugPrint("[DEBUG]: PUSH FAILED FOR USER SETTINGS WITH ERROR: $e");
    }
  }

  Future<void> pullRemoteChanges() async {
    debugPrint("[DEBUG] PULLING USER SETTINGS REMOTE CHANGES NOW!");
    // request for remote chnanges
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from("user_preferences")
          .select()
          .eq("user_id", userId)
          .maybeSingle();

      if (response == null) return;
      final userPrefsModel = UserPreferencesModelJson.fromJson(response);
      debugPrint(
        "[DEBUG] PULLING USER SETTINGS: cloud id: ${userPrefsModel.cloudId}",
      );
      await _localDb.updateUserPreferenceFromCloud(userPrefsModel);
    } catch (e) {
      debugPrint(
        "[DEBUG]: PULLING OF TASK REMOTE CHANGES FAILED WITH ERROR: $e",
      );
    }
  }
}
