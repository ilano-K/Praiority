import 'package:uuid/uuid.dart';

class UserPreferences {
  int? id;
  String? cloudId;
  final String? startWorkHours;
  final String? endWorkHours;
  final String? customPrompt;
  final bool isDarkMode;
  final bool isSynced;
  final bool isSetupComplete;

  UserPreferences({
    this.id,
    this.cloudId,
    this.startWorkHours,
    this.endWorkHours,
    this.customPrompt,
    this.isDarkMode = false,
    this.isSynced = false,
    this.isSetupComplete = false
  });

  UserPreferences copyWith({String? startWorkHours, String? endWorkHours, String? customPrompt, bool? isDarkMode, bool? isSetupComplete}){
    return UserPreferences(
      id: id,
      cloudId: cloudId,
      startWorkHours: startWorkHours ?? this.startWorkHours, 
      endWorkHours: endWorkHours ?? this.endWorkHours,
      customPrompt: customPrompt ?? this.customPrompt,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isSynced: false,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete
    );
  }

  factory UserPreferences.create(String startWorkHours, String endWorkHours, bool? isDarkMode){
    return UserPreferences(
      id: null,
      cloudId: Uuid().v4(),
      startWorkHours: startWorkHours, 
      endWorkHours: endWorkHours,
      customPrompt: null,
      isDarkMode: isDarkMode ?? false,
      isSynced: false,
      isSetupComplete: true,
    );
  }
  bool get needsSetup => !isSetupComplete;
}
