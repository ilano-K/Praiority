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
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';

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

// ✅ CHANGED TO STATEFUL WIDGET (To handle loading state)
class AddSheetHeader extends ConsumerStatefulWidget {
  final HeaderData data;

  const AddSheetHeader({super.key, required this.data});

  @override
  ConsumerState<AddSheetHeader> createState() => _AddSheetHeaderState();
}

class _AddSheetHeaderState extends ConsumerState<AddSheetHeader> {
  // 🔒 Local state to track saving process
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color displayColor = isDark ? widget.data.selectedColor.dark : widget.data.selectedColor.light;

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
              onPressed: () => AppDialogs.showConfirmation(
                context,
                title: "Delete ${widget.data.selectedType}",
                message: "Are you sure? This cannot be undone.",
                onConfirm: () async {
                  final task = widget.data.saveTemplate();
                  final controller = ref.read(calendarControllerProvider.notifier);
                  await controller.deleteTask(task);
                  
                  if (context.mounted) Navigator.pop(context); 
                },
              ),
            ),

            // ✅ OPTIMIZED SAVE BUTTON
            ElevatedButton(
              // Disable button if already saving (Prevents Double Tap)
              onPressed: _isSaving ? null : () async {
                setState(() => _isSaving = true); // Start Spinner

                var task = widget.data.saveTemplate();
                final controller = ref.read(calendarControllerProvider.notifier);

                if (task.title.isEmpty) {
                  // If it's a birthday, just call it "Birthday"
                  // Otherwise, use "Untitled Task" or "Untitled Event"
                  final defaultTitle = widget.data.selectedType == "Birthday" 
                      ? "Birthday" 
                      : "Untitled ${widget.data.selectedType}";
                      
                  task = task.copyWith(title: defaultTitle);
                }

                try {
                  // This runs fast now, but we show spinner just in case
                  await controller.addTask(task);
                  
                  if (context.mounted) Navigator.pop(context);
                } 
                on TimeConflictException {
                  // Keep sheet open so user can fix it
                  if (context.mounted) {
                    AppDialogs.showWarning(
                      context, 
                      title: "Schedule Conflict", 
                      message: "This task overlaps with an existing schedule. Please adjust the time."
                    );
                  }
                } 
                on EndBeforeStartException {
                  if (context.mounted) {
                    AppDialogs.showWarning(
                      context, 
                      title: "Oops! Check Time", 
                      message: "The end time cannot be before the start time."
                    );
                  }
                } 

                on DeadlineConflictException{
                  if (context.mounted){
                    AppDialogs.showWarning(
                      context, 
                      title: "Invalid End Time", 
                      message: "The task ends after its deadline. Please adjust the time."
                    );
                  }
                }
                catch (e) {
                  if (context.mounted) {
                    AppDialogs.showWarning(
                      context, 
                      title: "Error", 
                      message: "An unexpected error occurred"
                    );
                  }
                } 
                finally {
                  // Always stop spinner if we are still on this screen
                  if (mounted) {
                    setState(() => _isSaving = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onSurface,
                disabledBackgroundColor: colorScheme.primary.withOpacity(0.6), // Dim when loading
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                // Ensure minimum size keeps button stable when switching to spinner
                minimumSize: const Size(88, 48), 
              ),
              child: _isSaving 
                ? SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5, 
                      color: colorScheme.onSurface
                    )
                  )
                : const Text("Save", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
        
        const SizedBox(height: 20),

        // --- TITLE INPUT ---
        TextField(
          controller: widget.data.titleController,
          cursorColor: colorScheme.onSurface,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
          decoration: InputDecoration(
            // ✅ Change this line
            hintText: 'Untitled ${widget.data.selectedType}', 
            border: InputBorder.none,
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w900),
            contentPadding: EdgeInsets.zero,
          ),
        ),

        // --- DESCRIPTION INPUT ---
        TextField(
          controller: widget.data.descController,
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
                selectedColor: widget.data.selectedColor,
                onColorSelected: (newColor) {
                  widget.data.onColorSelected(newColor);
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
                widget.data.selectedColor.name,
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
  final bool isSelected = widget.data.selectedType == label;

  return GestureDetector(
    onTap: () {
      if (isSelected) return;

      final currentDraft = widget.data.saveTemplate();
      TaskType newType = label == 'Event' 
          ? TaskType.event 
          : (label == 'Birthday' ? TaskType.birthday : TaskType.task);
      final updatedDraft = currentDraft.copyWith(type: newType);

      // Close current sheet instantly
      Navigator.pop(context); 

      // Open new sheet with NO slide-up animation for a "flat" feel
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        transitionAnimationController: AnimationController(
          vsync: Navigator.of(context), 
          duration: Duration.zero, 
        )..forward(), 
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
        // --- 1. BACKGROUND: Now uses surface when selected ---
        color: isSelected ? colors.primary : Colors.transparent,
        
        // --- 2. BORDER: Stays onSurface for high contrast ---
        border: Border.all(
          color: isSelected ? colors.onSurface : colors.onSurface, 
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          // --- 3. TEXT: Stays onSurface ---
          color: colors.onSurface, 
          fontSize: 14,
        ),
      ),
    ),
  );
}
}