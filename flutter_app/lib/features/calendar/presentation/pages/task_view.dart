import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/date_picker.dart';
import '../widgets/tag_selector.dart';
import '../widgets/category_selector.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  // --- STATE FOR EXPANSION ---
  bool _isScheduledExpanded = false;

  // --- DUMMY DATA ---
  // NOTE: This is dummy data for demonstration purposes.
  final List<String> _dummyTasks = [
    "TASK NAME",
    "TASK NAME",
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // 1. My Scheduled Tasks (Animated Expansion)
          _buildExpandableCategory(
            context, 
            "My Scheduled Tasks", 
            2, 
            _isScheduledExpanded,
            () => setState(() => _isScheduledExpanded = !_isScheduledExpanded),
          ),
          
          _buildTaskCategory(context, "Pending", 0),
          _buildTaskCategory(context, "Completed", 0),
          _buildTaskCategory(context, "Past Deadlines", 0),

          const SizedBox(height: 40),
          Center(
            child: Text(
              "Note: Task names shown above are temporary dummy data.",
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.4),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: Animated Expandable Category ---
  Widget _buildExpandableCategory(BuildContext context, String title, int count, bool isExpanded, VoidCallback onTap) {
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
                  const Spacer(flex: 3),
                  Text(
                    "$title ($count)",
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
                      children: _dummyTasks.map((task) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          task,
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