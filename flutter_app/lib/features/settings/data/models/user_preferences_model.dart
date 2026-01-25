
import 'package:flutter_app/features/settings/domain/entities/user_preferences.dart';
import 'package:isar/isar.dart';

part 'user_preferences_model.g.dart';

@collection 
class UserPreferencesModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String userId;
  late String startWorkHours;
  late String endWorkHours;

  bool isSetupComplete = false;

  UserPreferences toEntity() => UserPreferences(
    id: userId,
    startWorkHours: startWorkHours,
    endWorkHours: endWorkHours,
    isSetupComplete: isSetupComplete
  );

  static UserPreferencesModel fromEntity(UserPreferences entity) {
    return UserPreferencesModel()
      ..userId = entity.id
      ..startWorkHours = entity.startWorkHours
      ..endWorkHours = entity.endWorkHours
      ..isSetupComplete = entity.isSetupComplete;
  }
}