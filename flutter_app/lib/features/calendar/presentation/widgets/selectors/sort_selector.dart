// File: lib/features/calendar/presentation/widgets/selectors/sort_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_notifier.dart';
import 'package:intl/intl.dart';
import 'category_selector.dart';
import 'date_picker.dart'; // This contains your custom pickDate(context)

class SortSelector extends ConsumerStatefulWidget {
  const SortSelector({super.key});

  @override
  ConsumerState<SortSelector> createState() => _SortSelectorState();
}

class _SortSelectorState extends ConsumerState<SortSelector> {
  String _selectedCategory = "None";
  DateTime? _selectedDate; // Persists the date locally in the sort menu

  void _applySort() {
    final categoryMap = {
      "Easy": TaskCategory.easy,
      "Average": TaskCategory.average,
      "Hard": TaskCategory.hard,
      "None": TaskCategory.none
    };

    final controller = ref.read(calendarControllerProvider.notifier);
    
    // Applying both filters to the TaskView
    controller.getTasksByCondition(
      category: categoryMap[_selectedCategory],
      start: _selectedDate != null ? DateUtils.dateOnly(_selectedDate!) : null,
      // end set to the very end of the selected day
      end: _selectedDate != null 
          ? DateUtils.dateOnly(_selectedDate!).add(const Duration(hours: 23, minutes: 59, seconds: 59)) 
          : null,
    );
    
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Keeps the date visible in the "Sort By" subtitle
    final String dateSubtitle = _selectedDate != null 
        ? DateFormat('MMMM d, y').format(_selectedDate!) 
        : "None";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sort By",
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.onSurface
                ),
              ),
              ElevatedButton(
                onPressed: _applySort,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onSurface,
                  elevation: 0,
                  fixedSize: const Size(90, 30),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Sort", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              )
            ],
          ),
          const SizedBox(height: 15),
          
          // --- DATE PICKER OPTION ---
          _buildSortOption(
            context,
            title: "Date",
            value: dateSubtitle, // Now persists and updates from "None"
            onTap: () async {
              // Using your specific pickDate class/function
              // Assuming pickDate returns Future<DateTime?>
              final DateTime? picked = await pickDate(context);
              
              if (picked != null) {
                setState(() {
                  _selectedDate = picked; // "Keeps" the date in the UI
                });
              }
            },
          ),
          
          // --- CATEGORY PICKER OPTION ---
          _buildSortOption(
            context,
            title: "Category",
            value: _selectedCategory,
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => CategorySelector(
                  currentCategory: _selectedCategory,
                  onCategorySelected: (val) {
                    setState(() => _selectedCategory = val);
                  },
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, {required String title, required String value, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        title, 
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)
      ),
      subtitle: Text(
        value, 
        style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.5))
      ),
    );
  }
}