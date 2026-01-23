// File: lib/features/calendar/presentation/widgets/add_header_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/dialogs/app_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- CORE ERRORS ---
import 'package:flutter_app/core/errors/task_conflict_exception.dart';
import 'package:flutter_app/core/errors/task_invalid_time_exception.dart';

// --- DOMAIN & CONTROLLERS ---
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_notifier.dart';

// --- SERVICES ---
import 'package:flutter_app/features/calendar/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_app/features/calendar/domain/usecases/save_task_usecase.dart';

// --- LOCAL WIDGETS ---
import '../selectors/color_selector.dart';
import 'add_task_sheet.dart'; 
import 'add_event_sheet.dart';
import 'add_birthday_sheet.dart'; 

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
        // --- HEADER ACTIONS ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // DELETE BUTTON
            IconButton(
              icon: Icon(Icons.delete_outline, size: 28, color: colorScheme.onSurface),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => AppDialogs.showConfirmation(
                context,
                title: "Delete ${data.selectedType}",
                message: "Are you sure you want to delete this ${data.selectedType.toLowerCase()}? This cannot be undone.",
                confirmLabel: "Delete",
                isDestructive: true,
                onConfirm: () async {
                  final task = data.saveTemplate();
                  await deleteTask(ref, task.id);
                  ref.invalidate(calendarControllerProvider);
                  if (context.mounted) Navigator.pop(context); // Close the sheet
                },
              ),
            ),

            // SAVE BUTTON
            ElevatedButton(
              onPressed: () async {
                final task = data.saveTemplate();
                try {
                  await saveTask(ref, task);
                  if (context.mounted) Navigator.pop(context);
                } on TaskConflictException {
                  AppDialogs.showWarning(
                    context, 
                    title: "Schedule Conflict", 
                    message: "This task overlaps with an existing schedule. Please adjust the time."
                  );
                } on TaskInvalidTimeException {
                  AppDialogs.showWarning(
                    context, 
                    title: "Invalid Time", 
                    message: "The end time must be after the start time. Please correct the duration."
                  );
                } catch (e) {
                  AppDialogs.showWarning(
                    context, 
                    title: "Error", 
                    message: "An unexpected error occurred: $e"
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
        
        const SizedBox(height: 20),

        // --- TITLE INPUT ---
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

        // --- DESCRIPTION INPUT ---
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

        // --- TYPE SELECTOR ---
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

        // --- COLOR SELECTOR ---
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => ColorSelector(
                selectedColor: data.selectedColor,
                onColorSelected: (newColor) {
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
                decoration: BoxDecoration(color: displayColor, shape: BoxShape.circle),
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

  // --- HELPERS ---

  Widget _buildTypeButton(String label, ColorScheme colors, BuildContext context) {
    final bool isSelected = data.selectedType == label;

    return GestureDetector(
      onTap: () {
        if (isSelected) return;

        final currentDraft = data.saveTemplate();
        TaskType newType = label == 'Event' ? TaskType.event : (label == 'Birthday' ? TaskType.birthday : TaskType.task);
        final updatedDraft = currentDraft.copyWith(type: newType);

        Navigator.pop(context); 
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            if (label == 'Task') return AddTaskSheet(task: updatedDraft);
            if (label == 'Event') return AddEventSheet(task: updatedDraft);
            return AddBirthdaySheet(task: updatedDraft);
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          border: Border.all(color: colors.onSurface, width: 1.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface, fontSize: 14),
        ),
      ),
    );
  }
}