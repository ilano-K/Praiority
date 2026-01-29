// File: lib/features/calendar/presentation/pages/task_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// --- IMPORT EDIT SHEETS & SELECTORS ---
import '../widgets/sheets/add_task_sheet.dart'; 
import '../widgets/sheets/add_event_sheet.dart';
import '../widgets/sheets/add_birthday_sheet.dart';
import '../widgets/dialogs/app_dialog.dart';
import '../widgets/selectors/sort_selector.dart'; // NEW IMPORT

class TaskView extends ConsumerStatefulWidget {
  const TaskView({super.key});

  @override
  ConsumerState<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends ConsumerState<TaskView> {
  bool _isScheduledExpanded = true;
  bool _isPendingExpanded = false;
  bool _isCompletedExpanded = false;

  @override
void initState() {
  super.initState();
  Future.microtask(() {
    final currentState = ref.read(calendarControllerProvider);
    // Only fetch "All" if we don't have any data yet
    if (currentState.value == null || currentState.value!.isEmpty) {
      ref.read(calendarControllerProvider.notifier).getTasksByCondition();
    }
  });
}
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

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent, 
      isScrollControlled: true,
      builder: (context) => const SortSelector(), // USING NEW CLASS
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
            Icon(Icons.assignment_outlined, color: colorScheme.onSurface, size: 28),
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
              _buildScheduledCategory(context, scheduled),
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

  Widget _buildScheduledCategory(BuildContext context, List<Task> tasks) {
    final colorScheme = Theme.of(context).colorScheme;
    final regularTasks = tasks.where((t) => t.type == TaskType.task).toList();
    final events = tasks.where((t) => t.type == TaskType.event).toList();
    final birthdays = tasks.where((t) => t.type == TaskType.birthday).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildCategoryHeader("My Scheduled Tasks", tasks.length, _isScheduledExpanded, 
              () => setState(() => _isScheduledExpanded = !_isScheduledExpanded)),
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: _isScheduledExpanded
                ? Column(
                    children: [
                      if (regularTasks.isNotEmpty) _buildSummaryHeader(context, "Tasks", colorScheme),
                      if (regularTasks.isNotEmpty) ...regularTasks.map((t) => _buildTaskItem(t, true)),
                      
                      if (events.isNotEmpty) _buildSummaryHeader(context, "Events", colorScheme),
                      if (events.isNotEmpty) ...events.map((t) => _buildTaskItem(t, true)),
                      
                      if (birthdays.isNotEmpty) _buildSummaryHeader(context, "Birthdays", colorScheme),
                      if (birthdays.isNotEmpty) ...birthdays.map((t) => _buildTaskItem(t, true)),
                      
                      const SizedBox(height: 12),
                    ],
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.w900, 
              color: colorScheme.onSurface, 
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: colorScheme.onSurface.withOpacity(0.1), 
              thickness: 1,
            )
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title, int count, bool isExpanded, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text("$title ($count)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.keyboard_arrow_down),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task, bool showActions) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDone = task.status == TaskStatus.completed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openTaskSheet(task),
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDone ? colorScheme.onSurface.withOpacity(0.4) : colorScheme.onSurface,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
          if (showActions)
            Row(
              children: [
                GestureDetector(
                  onTap: () => _updateTaskStatus(task, isDone ? TaskStatus.scheduled : TaskStatus.completed),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: isDone ? colorScheme.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.onSurface, width: 1.5),
                    ),
                    child: isDone ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                  ),
                ),
                const SizedBox(width: 14),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 30),
                  onPressed: () => AppDialogs.showConfirmation(
                    context, 
                    title: "Delete Task", 
                    message: "Remove '${task.title}' permanently?", 
                    confirmLabel: "Delete", 
                    isDestructive: true,
                    onConfirm: () async {
                      await ref.read(calendarControllerProvider.notifier).deleteTask(task);
                      ref.invalidate(calendarControllerProvider);
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildExpandableCategory(BuildContext context, List<Task> tasks, String title, bool isExpanded, VoidCallback onTap, {required bool showActions}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: colorScheme.secondary, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildCategoryHeader(title, tasks.length, isExpanded, onTap),
          if (isExpanded) ...tasks.map((task) => _buildTaskItem(task, showActions)).toList(),
        ],
      ),
    );
  }

  Future<void> _updateTaskStatus(Task task, TaskStatus newStatus) async {
    await ref.read(calendarControllerProvider.notifier).addTask(task.copyWith(status: newStatus));
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) ref.invalidate(calendarControllerProvider);
  }
}