import 'package:flutter_app/features/calendar/presentation/utils/date_time_utils.dart';
import 'package:flutter_app/features/settings/domain/entities/user_preferences.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'user_preferences_model.g.dart';

@collection
class UserPreferencesModel {
  Id id = Isar.autoIncrement;
  String? cloudId;
  String? startWorkHours;
  String? endWorkHours;
  String? customPrompt;
  bool isDarkMode = false;
  bool isSynced = false;
  bool isSetupComplete = false;
}

extension UserPreferencesModelMapper on UserPreferencesModel {
  UserPreferences toDomain() {
    return UserPreferences(
      id: id,
      cloudId: cloudId,
      startWorkHours: startWorkHours,
      endWorkHours: endWorkHours,
      customPrompt: customPrompt,
      isDarkMode: isDarkMode,
      isSynced: isSynced,
      isSetupComplete: isSetupComplete,
    );
  }
}

extension UserPreferencesMapper on UserPreferences {
  UserPreferencesModel toModel() {
    return UserPreferencesModel()
      ..id = id ?? Isar.autoIncrement
      ..cloudId = cloudId
      ..startWorkHours = startWorkHours
      ..endWorkHours = endWorkHours
      ..customPrompt = customPrompt
      ..isDarkMode = isDarkMode
      ..isSynced = isSynced
      ..isSetupComplete = isSetupComplete;
  }
}

extension UserPreferencesModelJson on UserPreferencesModel {
  /// Convert the model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': cloudId ?? const Uuid().v4(),
      'start_work_hours': toUtcHourMinute(startWorkHours!),
      'end_work_hours': toUtcHourMinute(endWorkHours!),
      'custom_prompt': customPrompt,
      "timezone": getUtcOffsetString(),
      'is_dark_mode': isDarkMode,
    };
  }

  /// Create a model from a JSON map
  static UserPreferencesModel fromJson(Map<String, dynamic> json) {
    final model = UserPreferencesModel();
    model.cloudId = json['id'] as String?;
    model.startWorkHours = json['start_work_hours'] as String?;
    model.endWorkHours = json['end_work_hours'] as String?;
    model.customPrompt = json['custom_prompt'] as String?;
    model.isDarkMode = json['is_dark_mode'] as bool;
    return model;
  }
}
