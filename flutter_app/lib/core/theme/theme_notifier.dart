// File: lib/core/services/theme/theme_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'themes.dart';
import 'dart:async';
import 'package:flutter_app/features/settings/presentation/managers/user_preferences_provider.dart';

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
    // Initial default shown immediately
    _loadSavedTheme();

    // Theme updates are applied explicitly by other controllers (for
    // example `AuthGate` after pulling remote prefs). Avoid listening to
    // `userPreferencesControllerProvider` here to prevent potential
    // provider dependency cycles.

    return lightMode;
  }

  Future<void> _loadSavedTheme() async {
    try {
      final repository = ref.read(userPreferencesRepositoryProvider);
      final prefs = await repository.getPreferences();
      if (prefs == null) return;
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
      final repository = ref.read(userPreferencesRepositoryProvider);
      final currentPrefs = await repository.getPreferences();
      if (currentPrefs == null) return;
      final updated = currentPrefs.copyWith(isDarkMode: newIsDark);
      await repository.savePreferences(updated);

      // trigger background push to remote
      final prefSyncController = ref.read(userPrefSyncServiceProvider);
      prefSyncController.pushLocalChanges();
    } catch (e) {
      debugPrint('[ThemeNotifier] failed to persist theme: $e');
    }
  }

  /// Public API to set the theme from outside the notifier.
  void setTheme(ThemeData theme) {
    state = theme;
  }

  /// Reset to the app default theme (light mode).
  void resetToDefault() {
    state = lightMode;
  }
}
