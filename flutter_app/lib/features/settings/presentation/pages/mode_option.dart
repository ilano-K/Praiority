// File: lib/features/settings/presentation/pages/mode_option.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/core/theme/theme_notifier.dart'; 
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModeOption extends ConsumerStatefulWidget { // Changed to Stateful for the loading logic
  const ModeOption({super.key});

  @override
  ConsumerState<ModeOption> createState() => _ModeOptionState();
}

class _ModeOptionState extends ConsumerState<ModeOption> {
  bool _isLoading = false; // Loading flag

  Future<void> _handleContinue() async {
    setState(() => _isLoading = true);

    // Optional: Add a small delay to show the loading state/process logic
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainCalendar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack( // Use Stack to overlay the loader
        children: [
          SafeArea(
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
                      Expanded(
                        child: _ModeCard(
                          label: "Light Mode",
                          iconPath: 'assets/images/LightLogo.png', 
                          isSelected: !isDark,
                          backgroundColor: Colors.white,
                          contentColor: Colors.black,
                          onTap: () {
                            if (isDark) ref.read(themeProvider.notifier).toggleTheme();
                          },
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: _ModeCard(
                          label: "Dark Mode",
                          iconPath: 'assets/images/DarkLogo.png',
                          isSelected: isDark,
                          backgroundColor: Colors.black,
                          contentColor: Colors.white,
                          onTap: () {
                            if (!isDark) ref.read(themeProvider.notifier).toggleTheme();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.onSurface, 
                        foregroundColor: colorScheme.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading 
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: colorScheme.surface,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            "Continue",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // --- FULL SCREEN OVERLAY ---
          if (_isLoading)
            AnimatedOpacity(
              opacity: _isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: colorScheme.surface.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- KEEP _ModeCard exactly as you had it ---
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
        height: 280,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(40),
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Image.asset(iconPath),
                ),
              ),
              const SizedBox(height: 10),
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