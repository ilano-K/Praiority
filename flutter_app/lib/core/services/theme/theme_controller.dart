// File: lib/core/services/theme/theme_controller.dart
// Purpose: Riverpod controller for managing theme state and persistence.
import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/theme/themes.dart';

class ThemeController with ChangeNotifier{
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData;
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    }
    else {
      themeData = lightMode;
    }
  }
}