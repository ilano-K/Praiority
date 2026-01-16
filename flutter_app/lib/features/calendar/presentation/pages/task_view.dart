import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/controllers/calendar_controller_providers.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/date_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/tag_selector.dart';
import '../widgets/category_selector.dart';

class TaskView extends ConsumerStatefulWidget {
  const TaskView({super.key});

  @override
  ConsumerState<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends ConsumerState<TaskView> {
  // --- STATE FOR EXPANSION ---
  bool _isScheduledExpanded = false;
  bool _isPendingExpanded = false;
  bool _isCompletedExpanded = false;
  bool _isPastDeadlineExpanded = false;
  // --- DUMMY DATA ---
  // NOTE: This is dummy data for demonstration purposes.

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tasksAsync = ref.watch(calendarControllerProvider);
    
    // final scheduleTasks = tasks.whenData((data) => data.where((t)=> t.status == TaskStatus.scheduled).toList());
    // final pending = tasks.whenData((data) => data.where((t)=> t.status == TaskStatus.unscheduled).toList());
    // final completed = tasks.whenData((data) => data.where((t)=> t.status == TaskStatus.completed).toList());
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
          final scheduled = tasks
              .where((t) => t.status == TaskStatus.scheduled)
              .toList();

          final pending = tasks
              .where((t) => t.status == TaskStatus.unscheduled)
              .toList();

          final completed = tasks
              .where((t) => t.status == TaskStatus.completed)
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              _buildExpandableCategory(
                context,
                scheduled, 
                "My Scheduled Tasks",
                _isScheduledExpanded,
                () => setState(() => _isScheduledExpanded = !_isScheduledExpanded),
              ),
              _buildExpandableCategory(
                context,
                pending, 
                "My Pending Tasks",
                _isPendingExpanded,
                () => setState(() => _isPendingExpanded = !_isPendingExpanded),
              ),
              _buildExpandableCategory(
                context,
                completed, 
                "My Completed Tasks",
                _isCompletedExpanded,
                () => setState(() => _isCompletedExpanded = !_isCompletedExpanded),
              ),

            ],
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER: Animated Expandable Category ---
  Widget _buildExpandableCategory(BuildContext context, List<Task>tasks, String title,  bool isExpanded, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    final tasksCount = tasks.length;
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
                  const Spacer(flex: 3),
                  Text(
                    "$title ($tasksCount)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(flex: 2),
                  // ANIMATION: Rotates the arrow smoothly
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0, 
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface),
                  ),
                ],
              ),
            ),
          ),
          // ANIMATION: Smoothly slides the list open/closed
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: tasks.map((task) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      )).toList(),
                    ),
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCategory(BuildContext context, String title, int count) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          const Spacer(flex: 3),
          Text(
            "$title ($count)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
          ),
          const Spacer(flex: 2),
          Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface),
        ],
      ),
    );
  }
  void _showSortSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
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
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onSurface,
                      elevation: 0,
                      fixedSize: const Size(90, 30),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Sort",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),

              // --- TRIGGER: DATE ---
              _buildSortOption(context, "Date", "None", () {
                pickDate(context);
              }),

              // --- TRIGGER: CATEGORY ---
              _buildSortOption(context, "Category", "None", () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CategorySelector(
                    currentCategory: "None",
                    onCategorySelected: (val) {},
                  ),
                );
              }),

              // --- TRIGGER: TAGS ---
              _buildSortOption(context, "Tags", "None", () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => TagSelector(
                    currentTag: "None",
                    availableTags: const [], // Empty for now
                    onTagSelected: (val) {},
                    onTagAdded: (val) {},
                    onTagRemoved: (val) {},
                  ),
                );
              }),

              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext context, String title, String value, VoidCallback onTap) {
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
      trailing: null,
    );
  }
}