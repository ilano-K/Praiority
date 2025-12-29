// File: lib/core/services/theme/theme_provider.dart
// Purpose: Exposes a Riverpod provider for the `ThemeController` so
// UI code can listen and react to theme changes.
import 'package:flutter_app/core/services/theme/theme_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = ChangeNotifierProvider<ThemeController>((ref) {
  return ThemeController();
});