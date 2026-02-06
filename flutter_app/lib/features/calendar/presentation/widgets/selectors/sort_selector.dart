// File: lib/features/calendar/presentation/widgets/selectors/sort_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/calendar/presentation/managers/task_view_controller.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/list_selector.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/priority_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:intl/intl.dart';
import 'category_selector.dart';
import 'date_picker.dart';

class SortSelector extends ConsumerStatefulWidget {
  const SortSelector({super.key});

  @override
  ConsumerState<SortSelector> createState() => _SortSelectorState();
}

class _SortSelectorState extends ConsumerState<SortSelector> {
  String _selectedCategory = "None";
  String _selectedPriority = "None";

  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;

  String _selectedTag = "None";
  List<String> _availableTags = [];

  @override
  void initState() {
    super.initState();
    ref.read(calendarRepositoryProvider).getAllTagNames().then((tags) {
      setState(() {
        _availableTags = tags.toList();
      });
    });
  }

  void _applySort() {
    final controller = ref.read(taskViewControllerProvider.notifier);

    final start = _selectedFromDate != null ? DateUtils.dateOnly(_selectedFromDate!) : null;
    final end = _selectedToDate != null
        ? DateUtils.dateOnly(_selectedToDate!).add(
            const Duration(hours: 23, minutes: 59, seconds: 59))
        : null;

    controller.filterTasks(
      category: taskCategoryFromString(_selectedCategory),
      priority: taskPriorityFromString(_selectedPriority),
      start: start,
      end: end,
      tag: _selectedTag,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final fromSubtitle = _selectedFromDate != null
        ? DateFormat('MMMM d, y').format(_selectedFromDate!)
        : "None";
    final toSubtitle = _selectedToDate != null
        ? DateFormat('MMMM d, y').format(_selectedToDate!)
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
                  color: colorScheme.onSurface,
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Sort",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // FROM date
          SortOption(
            title: "From",
            value: fromSubtitle,
            onTap: () async {
              final picked = await pickDate(context);
              if (picked != null) {
                setState(() {
                  _selectedFromDate = picked;
                  if (_selectedToDate != null &&
                      _selectedToDate!.isBefore(_selectedFromDate!)) {
                    _selectedToDate = _selectedFromDate;
                  }
                });
              }
            },
          ),

          // TO date
          SortOption(
            title: "To",
            value: toSubtitle,
            onTap: () async {
              final picked = await pickDate(context);
              if (picked != null) {
                setState(() {
                  _selectedToDate = picked;
                  if (_selectedFromDate != null &&
                      _selectedFromDate!.isAfter(_selectedToDate!)) {
                    _selectedFromDate = _selectedToDate;
                  }
                });
              }
            },
          ),

          // CATEGORY
          SortOption(
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

          // PRIORITY
          SortOption(
            title: "Priority",
            value: _selectedPriority,
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => PrioritySelector(
                  currentPriority: _selectedPriority,
                  onPrioritySelected: (val) {
                    setState(() => _selectedPriority = val);
                  },
                ),
              );
            },
          ),

          // TAGS
          SortOption(
            title: "Tag",
            value: _selectedTag != "None" ? _selectedTag : "None",
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => ListSelector(
                  title: "Select Tags",
                  options: _availableTags,
                  currentValue: _selectedTag,
                  onSelected: (val) => setState(() => _selectedTag = val),
                ),
              );
            },
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }
}

// --- NEW CLASS ---
class SortOption extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const SortOption({
    super.key,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 14, 
          color: colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      trailing: const Icon(Icons.keyboard_arrow_down),
    );
  }
}