class UserPreferences {
  final String id;
  final String startWorkHours;
  final String endWorkHours;
  final bool isSetupComplete;

  UserPreferences({
    required this.id,
    required this.startWorkHours,
    required this.endWorkHours,
    this.isSetupComplete = false
  });

  bool get needsSetup => !isSetupComplete;
}
