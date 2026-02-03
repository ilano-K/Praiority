// lib/features/calendar/presentation/widgets/selectors/repeat_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/custom_selector.dart';

class RepeatSelector extends StatelessWidget {
  final String currentRepeat;
  final ValueChanged<String> onRepeatSelected;

  const RepeatSelector({
    super.key,
    required this.currentRepeat,
    required this.onRepeatSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Repeat",
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 15),
          
          _buildOption(context, "None"),
          _buildOption(context, "Daily"),
          _buildOption(context, "Weekly"),
          _buildOption(context, "Monthly"),
          _buildOption(context, "Yearly"),
          _buildOption(context, "Custom"),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isSelected = currentRepeat == label;

    return ListTile(
      onTap: () {
        if (label == "Custom") {
          Navigator.pop(context); // Close RepeatSelector instantly

          // ✅ Updated: Slide-up animation for CustomSelector
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              barrierDismissible: true,
              transitionDuration: const Duration(milliseconds: 300),
              reverseTransitionDuration: const Duration(milliseconds: 200),
              pageBuilder: (context, _, __) => const Scaffold(
                backgroundColor: Colors.transparent,
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomSelector(),
                ),
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1), // Starts from bottom
                    end: Offset.zero,          // Moves up to center
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  )),
                  child: child,
                );
              },
            ),
          );
        } else {
          onRepeatSelected(label);
          Navigator.pop(context);
        }
      },
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: colorScheme.onSurface) : null,
    );
  }
}