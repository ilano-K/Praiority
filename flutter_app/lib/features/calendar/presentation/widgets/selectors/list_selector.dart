import 'package:flutter/material.dart';

class ListSelector extends StatelessWidget {
  final String title;
  final List<String> options;
  final String currentValue;
  final ValueChanged<String> onSelected;

  const ListSelector({
    super.key,
    required this.title,
    required this.options,
    required this.currentValue,
    required this.onSelected,
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
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          // Map options to the new SelectorOption class
          ...options.map((option) => SelectorOption(
            label: option,
            isSelected: currentValue == option,
            onTap: () {
              onSelected(option);
              Navigator.pop(context); // Close the sheet automatically
            },
          )),
          
          // Optional: Add bottom padding for safety
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// --- NEW CLASS ---
class SelectorOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectorOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero, // Aligns nicely with the title
      onTap: onTap,
      title: Text(
        label,
        style: TextStyle(
          // Text is Bold if selected
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          // Text is Black (onSurface) whether selected or not
          color: colorScheme.onSurface,
        ),
      ),
      // Checkmark is also Black (onSurface) when selected
      trailing: isSelected
          ? Icon(Icons.check, color: colorScheme.onSurface)
          : null,
    );
  }
}