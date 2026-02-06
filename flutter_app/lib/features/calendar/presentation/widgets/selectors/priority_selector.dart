// File: lib/features/calendar/presentation/widgets/selectors/priority_selector.dart
import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final String currentPriority;
  final ValueChanged<String> onPrioritySelected;

  const PrioritySelector({
    super.key,
    required this.currentPriority,
    required this.onPrioritySelected,
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
          const Text(
            "Select Priority",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          PriorityOption(
            label: "High",
            color: Colors.redAccent,
            isSelected: currentPriority == "High",
            onTap: () {
              onPrioritySelected("High");
              Navigator.pop(context);
            },
          ),
          PriorityOption(
            label: "Medium",
            color: Colors.orangeAccent,
            isSelected: currentPriority == "Medium",
            onTap: () {
              onPrioritySelected("Medium");
              Navigator.pop(context);
            },
          ),
          PriorityOption(
            label: "Low",
            color: Colors.green,
            isSelected: currentPriority == "Low",
            onTap: () {
              onPrioritySelected("Low");
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// --- NEW CLASS ---
class PriorityOption extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const PriorityOption({
    super.key,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero, // Aligns nicely with the title
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color,
        radius: 6,
      ),
      title: Text(
        label,
        style: TextStyle(
          // Bold when selected
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          // Explicitly define text color for visibility in both themes
          color: colorScheme.onSurface,
        ),
      ),
      // Checkmark matches theme text color
      trailing: isSelected
          ? Icon(Icons.check, color: colorScheme.onSurface)
          : null,
    );
  }
}