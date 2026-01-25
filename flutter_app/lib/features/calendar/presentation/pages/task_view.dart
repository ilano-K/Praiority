import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_notifier.dart';
import 'package:flutter_app/features/calendar/domain/usecases/delete_task_usecase.dart';
import 'package:flutter_app/features/calendar/domain/usecases/save_task_usecase.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/dialogs/app_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/selectors/category_selector.dart';

// --- IMPORT EDIT SHEETS ---
import '../widgets/sheets/add_task_sheet.dart'; 
import '../widgets/sheets/add_event_sheet.dart';
import '../widgets/sheets/add_birthday_sheet.dart';

class TaskView extends ConsumerStatefulWidget {
  const TaskView({super.key});

  @override
  ConsumerState<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends ConsumerState<TaskView> {
  bool _isScheduledExpanded = true;
  bool _isPendingExpanded = false;
  bool _isCompletedExpanded = false;

  void _openTaskSheet(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        if (task.type == TaskType.event) {
          return AddEventSheet(task: task);
        } else if (task.type == TaskType.birthday) {
          return AddBirthdaySheet(task: task);
        } else {
          return AddTaskSheet(task: task);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tasksAsync = ref.watch(calendarControllerProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.assignment_turned_in_outlined, color: colorScheme.onSurface, size: 28),
            const SizedBox(width: 12),
            const Text(
              "Tasks",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_vert, color: colorScheme.onSurface, size: 28),
            onPressed: () => _showSortSheet(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: colorScheme.onSurface.withOpacity(0.1), height: 1),
        ),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (tasks) {
          final scheduled = tasks.where((t) => t.status == TaskStatus.scheduled).toList();
          final pending = tasks.where((t) => t.status == TaskStatus.unscheduled).toList();
          final completed = tasks.where((t) => t.status == TaskStatus.completed).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              _buildExpandableCategory(context, scheduled, "My Scheduled Tasks", _isScheduledExpanded, 
                  () => setState(() => _isScheduledExpanded = !_isScheduledExpanded), showActions: true),
              _buildExpandableCategory(context, pending, "My Pending Tasks", _isPendingExpanded, 
                  () => setState(() => _isPendingExpanded = !_isPendingExpanded), showActions: false),
              _buildExpandableCategory(context, completed, "My Completed Tasks", _isCompletedExpanded, 
                  () => setState(() => _isCompletedExpanded = !_isCompletedExpanded), showActions: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExpandableCategory(BuildContext context, List<Task> tasks, String title, bool isExpanded, VoidCallback onTap, {required bool showActions}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "$title (${tasks.length})",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                    ),
                  ),
                  SizedBox(
                    width: 54,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 32,
                        child: AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 400), // Slightly slower for smoother feel
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    children: tasks.map((task) {
                      final bool isDone = task.status == TaskStatus.completed;

                      return Padding(
                        key: ValueKey(task.id), // Added ValueKey to prevent layout flickering
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _openTaskSheet(task),
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: isDone ? FontStyle.italic : FontStyle.normal,
                                    color: isDone ? colorScheme.onSurface.withOpacity(0.4) : colorScheme.onSurface,
                                    decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                            
                            if (showActions) 
                              SizedBox(
                                width: 54,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () => _updateTaskStatus(task, isDone ? TaskStatus.scheduled : TaskStatus.completed),
                                      child: Container(
                                        width: 18, 
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: isDone ? colorScheme.primary : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: colorScheme.onSurface, width: 1.2),
                                        ),
                                        child: isDone ? Icon(Icons.check, size: 12, color: colorScheme.onSurface) : null,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                      width: 32, height: 32,
                                      child: IconButton(
                                        icon: Icon(Icons.delete_outline, size: 22, color: colorScheme.onSurface),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => AppDialogs.showConfirmation(
                                          context, title: "Delete Task", message: "Remove '${task.title}' permanently?", confirmLabel: "Delete", isDestructive: true,
                                          onConfirm: () async {
                                            final controller = ref.read(calendarControllerProvider.notifier);
                                            await controller.deleteTask(task);
                                            ref.invalidate(calendarControllerProvider);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: SMOOTH TRANSITION HELPER ---
  Future<void> _updateTaskStatus(Task task, TaskStatus newStatus) async {
    final controller = ref.read(calendarControllerProvider.notifier);
    final updatedTask = task.copyWith(status: newStatus);
    
    // 1. First, save the status change to the DB
    await controller.addTask(updatedTask);
    
    // 2. Add a tiny delay (300ms) so the user sees the italic/faded style
    // before the item physically moves to the next section.
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 3. Now refresh the UI state
    if (mounted) {
      ref.invalidate(calendarControllerProvider);
    }
  }

  void _showSortSheet(BuildContext context) {
    String _selectedCategory = "None";
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Sort By", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                ElevatedButton(
                  onPressed: () async {
                    sortTasks(_selectedCategory);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onSurface, elevation: 0, fixedSize: const Size(90, 30), padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text("Sort", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                )
              ],
            ),
            const SizedBox(height: 15),
            _buildSortOption(context, "Date", "None", () => pickDate(context)),
            _buildSortOption(context, "Category", _selectedCategory, () {
              showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) => CategorySelector(currentCategory: "None", onCategorySelected: (val) {setState(() {
                _selectedCategory = val;
              });}));
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void sortTasks(String category){
    final category_map = {
      "Easy": TaskCategory.easy,
      "Average": TaskCategory.average,
      "Hard": TaskCategory.hard,
      "None": TaskCategory.none
    };

    final controller = ref.read(calendarControllerProvider.notifier);
    controller.getTasksByCondition(category: category_map[category]);
  }


  Widget _buildSortOption(BuildContext context, String title, String value, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero, onTap: onTap,
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
      subtitle: Text(value, style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.5))),
    );
  }
}