import 'package:flutter_app/features/calendar/data/models/task_tag_model.dart';
import 'package:flutter_app/features/settings/data/models/user_preferences_model.dart';
// File: lib/core/services/local_database_service.dart
// Purpose: Service responsible for initializing and exposing the local Isar DB.
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/calendar/data/models/task_model.dart';

class LocalDatabaseService {
  late Isar isar;

  Future<void> init() async {
    // app directory
    final appDir = await getApplicationDocumentsDirectory();

    // open local database (isar)
    isar = await Isar.open(
      [TaskModelSchema, TaskTagModelSchema, UserPreferencesModelSchema],
      directory: appDir.path,
      inspector: true, // debug
      );
  }

  Future<void> clearDatabase() async {
    if (isar.isOpen) {
      await isar.writeTxn(() async {
        await isar.clear(); 
      });
    }
  }
}