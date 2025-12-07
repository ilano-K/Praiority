import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final String currentCategory;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.currentCategory,
    required this.onCategorySelected,
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
            "Select Category",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildOption(context, "Easy"),
          _buildOption(context, "Average"),
          _buildOption(context, "Hard"),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label) {
    bool isSelected = currentCategory == label;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: () {
        onCategorySelected(label);
        Navigator.pop(context);
      },
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