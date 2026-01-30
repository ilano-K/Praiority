// File: lib/features/settings/presentation/pages/mode_option.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/theme_notifier.dart'; 
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModeOption extends ConsumerWidget {
  const ModeOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "What do you prefer?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 50),

              Row(
                children: [
                  // --- LIGHT MODE CARD ---
                  Expanded(
                    child: _ModeCard(
                      label: "Light Mode",
                      iconPath: 'assets/images/LightLogo.png', 
                      isSelected: !isDark,
                      backgroundColor: Colors.white,
                      contentColor: Colors.black, // Text and icon color
                      onTap: () {
                        if (isDark) ref.read(themeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),
                  const SizedBox(width: 25),
                  // --- DARK MODE CARD ---
                  Expanded(
                    child: _ModeCard(
                      label: "Dark Mode",
                      iconPath: 'assets/images/DarkLogo.png',
                      isSelected: isDark,
                      backgroundColor: Colors.black,
                      contentColor: Colors.white, // Text and icon color
                      onTap: () {
                        if (!isDark) ref.read(themeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),

              // --- DYNAMIC CONTINUE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainCalendar()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onSurface, 
                    foregroundColor: colorScheme.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String label;
  final String iconPath;
  final bool isSelected;
  final Color backgroundColor;
  final Color contentColor;
  final VoidCallback onTap;

  const _ModeCard({
    required this.label,
    required this.iconPath,
    required this.isSelected,
    required this.backgroundColor,
    required this.contentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 280, // Taller to accommodate the text inside
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(40),
          // Selection border uses your tertiary/clicked color for consistency
          border: isSelected 
              ? Border.all(color: Theme.of(context).colorScheme.tertiary, width: 4) 
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.3 : 0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- ICON ---
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Image.asset(iconPath),
                ),
              ),
              const SizedBox(height: 10),
              // --- TEXT INSIDE THE CARD ---
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: contentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}