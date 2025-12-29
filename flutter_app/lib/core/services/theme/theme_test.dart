// File: lib/core/services/theme/theme_test.dart
// Purpose: Tests for theme switching and appearance.

import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/theme/button_test.dart';
import 'package:flutter_app/core/services/theme/cell.dart';
import 'package:flutter_app/core/services/theme/theme_controller.dart';
import 'package:provider/provider.dart';

class ThemeTest extends StatelessWidget {
  const ThemeTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Theme.of(context).colorScheme.surface,
      body: Center(
        child: MyCell(
          color: Theme.of(context).colorScheme.primary,
            child: ButtonTest(
            color: Theme.of(context).colorScheme.secondary, 
            onTap: () {
              Provider.of<ThemeController>(context, listen: false).toggleTheme();
            }
          ),
        ),
          
      )
    );
  }
}