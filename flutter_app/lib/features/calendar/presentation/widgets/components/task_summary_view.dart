// File: lib/features/calendar/presentation/widgets/dialogs/task_summary_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';

class TaskSummaryView extends StatelessWidget {
  final DateTime date;
  final List<Task> tasks;
  final Function(Task) onTaskTap;

  const TaskSummaryView({
    super.key,
    required this.date,
    required this.tasks,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // --- REFINED FILTER LOGIC BY TYPE ---
    // This ensures Events stay in their section whether they are all-day or timed.
    final regularTasks = tasks.where((t) => t.type == TaskType.task).toList();
    final events = tasks.where((t) => t.type == TaskType.event).toList();
    final birthdays = tasks.where((t) => t.type == TaskType.birthday).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, colorScheme),
          const SizedBox(height: 10),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Strictly Ordered: Tasks -> Events -> Birthdays
                  _buildSection(context, "Tasks", regularTasks, colorScheme),
                  _buildSection(context, "Events", events, colorScheme),
                  _buildSection(context, "Birthdays", birthdays, colorScheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Task> sectionTasks, ColorScheme colorScheme) {
    if (sectionTasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.w900, 
                  color: colorScheme.onSurface, // Black Label
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
        ),
        ...sectionTasks.map((task) => _buildTaskItem(context, task, colorScheme)),
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pop(context);
          onTaskTap(task);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.12), // Grey Vibe
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withOpacity(0.06), // Black Shadow
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],

          ),
          child: Text(
            task.title.isEmpty ? "Untitled Task" : task.title,
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface, // Black text
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM d, yyyy').format(date),
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: colorScheme.onSurface, size: 28),
        ),
      ],
    );
  }
}