// File: lib/core/services/theme/theme_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'themes.dart';

// 1. Define the Provider using the new Notifier
final themeProvider = NotifierProvider<ThemeNotifier, ThemeData>(() {
  return ThemeNotifier();
});

// 2. The Notifier class replaces the Controller
class ThemeNotifier extends Notifier<ThemeData> {
  @override
  ThemeData build() {
    // Return the initial state
    return lightMode;
  }

  void toggleTheme() {
    // In Riverpod Notifiers, 'state' represents the current value
    state = (state == lightMode) ? darkMode : lightMode;
  }
}