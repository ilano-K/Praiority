// lib/features/calendar/presentation/widgets/selectors/repeat_selector.dart

import 'package:flutter/material.dart';
import 'custom_selector.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Repeat",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildOption(context, "None"),
          _buildOption(context, "Daily"),
          _buildOption(context, "Weekly"),
          _buildOption(context, "Monthly"),
          _buildOption(context, "Yearly"),
          const Divider(),
          _buildOption(context, "Custom"),
        ],
      ),
    );
  }

Widget _buildOption(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isSelected = currentRepeat == label;

    return ListTile(
      onTap: () async {
        if (label == "Custom") {
          // 1. Wait for the custom data
          final customData = await Navigator.of(context).push(
            PageRouteBuilder(
              // ... your existing PageRouteBuilder logic ...
              pageBuilder: (context, _, __) => const Scaffold(
                backgroundColor: Colors.transparent,
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomSelector(),
                ),
              ),
            ),
          );

          // 2. If data was saved, pass it back to the AddEventSheet
          if (customData != null && context.mounted) {
            Navigator.pop(context, customData);
          }
        } else {
          // Standard preset: just pass the string
          Navigator.pop(context, label);
        }
      },
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
    );
  }
}