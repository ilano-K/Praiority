// File: lib/features/calendar/presentation/widgets/add_header_sheet.dart
// Purpose: Header UI for add/edit sheets, shows title and actions.
import 'package:flutter/material.dart';
import 'package:flutter_app/core/errors/task_conflict_exception.dart';
import 'package:flutter_app/features/calendar/domain/entities/date_range.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/controllers/calendar_controller_providers.dart';
import 'package:flutter_app/features/calendar/presentation/services/save_task.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import necessary widgets and data structures
import 'color_selector.dart';
import 'add_task_sheet.dart'; 
import 'add_event_sheet.dart';
import 'add_birthday_sheet.dart'; 

// Define a common interface for the header's state data
class HeaderData {
  final String selectedType;
  final CalendarColor selectedColor;
  final TextEditingController titleController;
  final TextEditingController descController;
  final ValueChanged<String> onTypeSelected;
  final ValueChanged<CalendarColor> onColorSelected;
  final Task Function() saveTemplate;

  HeaderData({
    required this.selectedType,
    required this.selectedColor,
    required this.titleController,
    required this.descController,
    required this.onTypeSelected,
    required this.onColorSelected,
    required this.saveTemplate,
  });
}


class AddSheetHeader extends ConsumerWidget {
  final HeaderData data;

  const AddSheetHeader({super.key, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color displayColor = isDark ? data.selectedColor.dark : data.selectedColor.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER (Close & Save Buttons) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.close, size: 28, color: colorScheme.onSurface),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              onPressed: () async {
                final task = data.saveTemplate();
                final taskDay = dateOnly(task.startTime!);

                final dateRange = DateRange(scope: CalendarScope.day, startTime: DateTime.now());
                try {
                    await saveTask(ref, task);

                    // only runs if NO conflict
                    ref.invalidate(calendarControllerProvider(dateRange));
                    Navigator.pop(context);
                  } on TaskConflictException {
                    // TEMPORARY ONLY 
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('This task conflicts with another task'),
                      ),
                    );
                  }
                }, // Use the provided save callback
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Save",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // --- TITLE ---
        TextField(
          controller: data.titleController,
          cursorColor: colorScheme.onSurface,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Add Title',
            border: InputBorder.none,
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w900),
            contentPadding: EdgeInsets.zero,
          ),
        ),

        // --- DESCRIPTION ---
        TextField(
          controller: data.descController,
          cursorColor: colorScheme.onSurface,
          style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.8)),
          decoration: InputDecoration(
            hintText: 'Add Description',
            border: InputBorder.none,
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
            contentPadding: EdgeInsets.zero,
          ),
        ),

        const SizedBox(height: 25),

        // --- TYPE BUTTONS ---
        Row(
          children: [
            _buildTypeButton("Task", colorScheme, context),
            const SizedBox(width: 12),
            _buildTypeButton("Event", colorScheme, context),
            const SizedBox(width: 12),
            _buildTypeButton("Birthday", colorScheme, context),
          ],
        ),

        const SizedBox(height: 20),

        // --- COLOR PICKER ---
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => ColorSelector(
                selectedColor: data.selectedColor,
                onColorSelected: (newColor) {
                  // Notify the parent sheet to update its state
                  data.onColorSelected(newColor);
                  Navigator.pop(context);
                },
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: displayColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                data.selectedColor.name,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: colorScheme.onSurface),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        Divider(thickness: 1, color: colorScheme.onSurface.withOpacity(0.1)),
        const SizedBox(height: 10),
      ],
    );
  }

  // --- WIDGET HELPER: Type Button (Handles switching between sheets) ---
  Widget _buildTypeButton(String label, ColorScheme colors, BuildContext context) {
      bool isSelected = data.selectedType == label;

      return GestureDetector(
        onTap: () {
        if (isSelected) return;

        // 1. Capture the current data
        final currentDraft = data.saveTemplate();

        // 2. Determine new type
        TaskType newType;
        if (label == 'Event') {
          newType = TaskType.event;
        } else if (label == 'Birthday') newType = TaskType.birthday;
        else newType = TaskType.task;

        // 3. Create the update. 
        // IMPORTANT: Ensure you pass the tags and color here too!
        final updatedDraft = currentDraft.copyWith(
          type: newType,
          // This ensures tags and basic info move to the next sheet's constructor
        );

        if (label == 'Task') {
          _switchSheet(context, AddTaskSheet(task: updatedDraft));
        } else if (label == 'Event') {
          _switchSheet(context, AddEventSheet(task: updatedDraft));
        } else if (label == 'Birthday') {
          _switchSheet(context, AddBirthdaySheet(task: updatedDraft));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          border: Border.all(
            color: colors.onSurface,
            width: 1.2
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _switchSheet(BuildContext context, Widget newSheet) {
    // Pop the current sheet
    Navigator.pop(context); 
    
    // Re-open with the new sheet (which now contains the draft data)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => newSheet,
    );
  }
}