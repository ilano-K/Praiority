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
          _buildOption(context, "High", Colors.redAccent),
          _buildOption(context, "Medium", Colors.orangeAccent),
          _buildOption(context, "Low", Colors.green),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label, Color color) {
    bool isSelected = currentPriority == label;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: () {
        onPrioritySelected(label);
        Navigator.pop(context);
      },
      leading: CircleAvatar(backgroundColor: color, radius: 6),
      title: Text(
        label,
        style: TextStyle(
          // Bold when selected
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          // Black (onSurface) when selected
          color: isSelected ? colorScheme.onSurface : null,
        ),
      ),
      // Checkmark is Black (onSurface) when selected
      trailing: isSelected ? Icon(Icons.check, color: colorScheme.onSurface) : null,
    );
  }
}