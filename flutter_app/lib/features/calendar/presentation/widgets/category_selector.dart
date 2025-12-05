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
            "Select Difficulty", // Changed title to match Easy/Hard context
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
    return ListTile(
      onTap: () {
        onCategorySelected(label);
        Navigator.pop(context);
      },
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check) : null,
    );
  }
}