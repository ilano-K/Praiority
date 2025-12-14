import 'package:flutter_app/core/services/theme/theme_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = ChangeNotifierProvider<ThemeController>((ref) {
  return ThemeController();
});