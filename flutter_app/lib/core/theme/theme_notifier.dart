// File: lib/core/services/theme/theme_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'themes.dart';
import 'dart:async';
import 'package:flutter_app/features/settings/presentation/managers/settings_provider.dart';

// 1. Define the Provider using the new Notifier
final themeProvider = NotifierProvider<ThemeNotifier, ThemeData>(() {
  return ThemeNotifier();
});

// 2. The Notifier class replaces the Controller
class ThemeNotifier extends Notifier<ThemeData> {
  @override
  ThemeData build() {
    // Return the initial state immediately, then load persisted choice
    // and apply it asynchronously so UI is responsive on startup.
    _loadSavedTheme();
    return lightMode;
  }

  Future<void> _loadSavedTheme() async {
    try {
      final repository = ref.read(settingsRepositoryProvider);
      final prefs = await repository.getPreferences();
      final isDark = prefs.isDarkMode;
      state = isDark ? darkMode : lightMode;
    } catch (e) {
      debugPrint('[ThemeNotifier] failed to load saved theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    // Toggle UI state immediately
    final newIsDark = !(state == darkMode);
    state = newIsDark ? darkMode : lightMode;

    // Persist the choice to local settings and trigger sync
    try {
      final repository = ref.read(settingsRepositoryProvider);
      final currentPrefs = await repository.getPreferences();
      final updated = currentPrefs.copyWith(isDarkMode: newIsDark);
      await repository.savePreferences(updated);

      // trigger background push to remote
      final prefSyncController = ref.read(userPrefSyncServiceProvider);
      prefSyncController.pushLocalChanges();
    } catch (e) {
      debugPrint('[ThemeNotifier] failed to persist theme: $e');
    }
  }
}