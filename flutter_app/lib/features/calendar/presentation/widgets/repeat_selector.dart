import 'package:flutter/material.dart';

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
              color: colorScheme.onSurface
            ),
          ),
          const SizedBox(height: 15),
          
          // Repeat Options
          _buildOption(context, "None"),
          _buildOption(context, "Daily"),
          _buildOption(context, "Weekly"),
          _buildOption(context, "Every 2 weeks"),
          _buildOption(context, "Monthly"),
          _buildOption(context, "Yearly"),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isSelected = currentRepeat == label;

    return ListTile(
      onTap: () {
        onRepeatSelected(label);
        Navigator.pop(context);
      },
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          // Purple if selected, Black/White if not
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      // Checkmark on the right
      trailing: isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
    );
  }
}