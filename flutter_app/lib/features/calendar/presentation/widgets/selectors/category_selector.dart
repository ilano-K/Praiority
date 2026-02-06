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
          CategoryOption(
            label: "Easy",
            isSelected: currentCategory == "Easy",
            onTap: () {
              onCategorySelected("Easy");
              Navigator.pop(context);
            },
          ),
          CategoryOption(
            label: "Average",
            isSelected: currentCategory == "Average",
            onTap: () {
              onCategorySelected("Average");
              Navigator.pop(context);
            },
          ),
          CategoryOption(
            label: "Hard",
            isSelected: currentCategory == "Hard",
            onTap: () {
              onCategorySelected("Hard");
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class CategoryOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
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