import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/interactive_row.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/pick_time.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/reminder_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// UI Components
import '../selectors/priority_selector.dart';
import '../selectors/category_selector.dart';
import '../selectors/tag_selector.dart';
import '../selectors/color_selector.dart';
import 'add_header_sheet.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  final Task? task;
  final DateTime? initialDate;

  const AddTaskSheet({super.key, this.task, this.initialDate});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  // --- STATE VARIABLES ---
  String _selectedType = 'Task';
  bool _isSmartScheduleEnabled = true;
  String _priority = "Medium";
  String _category = "None";
  List<String> _selectedTags = [];
  CalendarColor _selectedColor = appEventColors[0];
  List<String> _tagsList = [];
  bool _advancedExpanded = false;
  bool _movableByAI = false;
  bool _setNonConfliction = true;

  // --- REMINDERS STATE (Updated) ---
  bool _hasReminder = true;
  // Replaced absolute Date/Time with relative offsets
  List<Duration> _selectedOffsets = [const Duration(minutes: 10)];

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Date & Time
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late DateTime _deadlineDate;
  late TimeOfDay _deadlineTime;

  @override
  void initState() {
    super.initState();

    final DateTime baseDate;
    if (widget.task != null) {
      baseDate = widget.task!.startTime ?? DateTime.now();
    } else if (widget.initialDate != null) {
      baseDate = widget.initialDate!;
    } else {
      baseDate = DateTime.now();
    }

    _startDate = baseDate;
    _startTime = TimeOfDay.fromDateTime(baseDate);
    _endTime = TimeOfDay.fromDateTime(baseDate.add(const Duration(hours: 1)));
    _deadlineDate = widget.task?.deadline ?? baseDate;
    _deadlineTime = const TimeOfDay(hour: 23, minute: 59);

    if (widget.task != null) {
      _prefillFromTask(widget.task!);
    }
  }

  String _enumToString(dynamic enumValue) {
    final name = enumValue.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }

  void _prefillFromTask(Task task) {
    _titleController.text = task.title;
    _descController.text = task.description ?? "";
    _isSmartScheduleEnabled = task.isSmartSchedule;
    _startDate = task.startTime ?? DateTime.now();
    _startTime = TimeOfDay.fromDateTime(task.startTime ?? DateTime.now());
    _endTime = TimeOfDay.fromDateTime(
      task.endTime ?? DateTime.now().add(const Duration(hours: 1)),
    );
    _deadlineDate = task.deadline ?? DateTime.now();
    _deadlineTime = TimeOfDay.fromDateTime(task.deadline ?? DateTime.now());
    _selectedTags = task.tags;
    _priority = _enumToString(task.priority);
    _category = _enumToString(task.category);
    _movableByAI = task.isAiMovable;
    _setNonConfliction = task.isConflicting;

    if (task.title == "Untitled Task" ||
        task.title == "Untitled Event" ||
        task.title == "Birthday") {
      _titleController.text = "";
    } else {
      _titleController.text = task.title;
    }

    // Prefill offsets
    if (task.reminderOffsets.isNotEmpty) {
      _selectedOffsets = List.from(task.reminderOffsets);
      _hasReminder = true;
    } else {
      _hasReminder = false;
      _selectedOffsets = [const Duration(minutes: 10)]; // Default if re-enabled
    }

    if (task.colorValue != null) {
      _selectedColor = appEventColors.firstWhere(
        (c) =>
            c.light.value == task.colorValue || c.dark.value == task.colorValue,
        orElse: () => appEventColors[0],
      );
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // Helper to format offsets for display (e.g. "10m, 1h before")
  String _formatOffsets() {
    if (_selectedOffsets.isEmpty) return "None";

    final List<String> parts = _selectedOffsets.map((d) {
      if (d.inMinutes == 0) return "At time of event";
      if (d.inMinutes < 60) return "${d.inMinutes}m";
      if (d.inHours < 24) return "${d.inHours}h";
      return "${d.inDays}d";
    }).toList();

    return "${parts.join(", ")} before";
  }

  Task createTaskSaveTemplate(bool isDark) {
    final colorValue = isDark
        ? _selectedColor.dark.value
        : _selectedColor.light.value;
    final title = _titleController.text.trim();

    var baseTask = Task.create(
      type: TaskType.task,
      title: title,
      description: _descController.text.trim(),
      priority: taskPriorityFromString(_priority),
      category: taskCategoryFromString(_category),
      tags: _selectedTags,
      colorValue: colorValue,
      isAllDay: false,
      recurrenceRule: null,
      isAiMovable: _movableByAI,
      isConflicting: _setNonConfliction,
      isSmartSchedule: _isSmartScheduleEnabled,
      // Save offsets if switch is ON
      reminderOffsets: _hasReminder ? _selectedOffsets : [],
    );

    final scheduleData = _isSmartScheduleEnabled
        ? {
            "startTime": null,
            "endTime": null,
            "deadline": null,
            "status": TaskStatus.pending,
          }
        : {
            "startTime": _combineDateAndTime(_startDate, _startTime),
            "endTime": _combineDateAndTime(_startDate, _endTime),
            "deadline": _combineDateAndTime(_deadlineDate, _deadlineTime),
            "status": TaskStatus.scheduled,
          };

    baseTask = baseTask.copyWith(
      startTime: scheduleData["startTime"] as DateTime?,
      endTime: scheduleData["endTime"] as DateTime?,
      deadline: scheduleData["deadline"] as DateTime?,
      status: scheduleData["status"] as TaskStatus,
    );

    return widget.task != null
        ? widget.task!.copyWith(
            title: baseTask.title,
            description: baseTask.description,
            startTime: baseTask.startTime,
            endTime: baseTask.endTime,
            deadline: baseTask.deadline,
            priority: baseTask.priority,
            category: baseTask.category,
            tags: baseTask.tags,
            status: baseTask.status,
            colorValue: baseTask.colorValue,
            isAiMovable: baseTask.isAiMovable,
            isConflicting: baseTask.isConflicting,
            reminderOffsets: baseTask.reminderOffsets, // Update offsets
          )
        : baseTask;
  }

  void _showOffsetSelector(BuildContext context) {
    final taskStart = _combineDateAndTime(_startDate, _startTime);

    ReminderSelector.show(
      parentContext: context, // ✅ Pass the sheet's context here
      selectedOffsets: _selectedOffsets,
      taskStartTime: taskStart,
      onChanged: (newOffsets) {
        setState(() {
          _selectedOffsets = newOffsets;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color sheetBackground = colorScheme.inversePrimary;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final tagsAsync = ref.watch(tagsProvider);
    _tagsList = tagsAsync.valueOrNull ?? [];

    final headerData = HeaderData(
      selectedType: _selectedType,
      selectedColor: _selectedColor,
      titleController: _titleController,
      descController: _descController,
      onTypeSelected: (type) => setState(() => _selectedType = type),
      onColorSelected: (color) => setState(() => _selectedColor = color),
      saveTemplate: () => createTaskSaveTemplate(isDark),
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: sheetBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AddSheetHeader(data: headerData),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- REMINDERS ROW (Kept UI same) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Reminders",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _hasReminder
                                  ? "You'll get a notification"
                                  : "Reminders are turned off",
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: _hasReminder,
                          activeTrackColor: colorScheme.primary,
                          onChanged: (val) =>
                              setState(() => _hasReminder = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. SMART SCHEDULE TOGGLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Smart Schedule",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _isSmartScheduleEnabled,
                          activeTrackColor: colorScheme.primary,
                          onChanged: (val) =>
                              setState(() => _isSmartScheduleEnabled = val),
                        ),
                      ),
                    ],
                  ),
                  if (_isSmartScheduleEnabled) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "an AI-based system that schedules your tasks\nat the best time for you.",
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),

                  // 3. PRIORITY
                  InteractiveInputRow(
                    label: "Priority",
                    value: _priority,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => PrioritySelector(
                        currentPriority: _priority,
                        onPrioritySelected: (val) =>
                            setState(() => _priority = val),
                      ),
                    ),
                  ),

                  // 2. START & END TIME
                  if (!_isSmartScheduleEnabled) ...[
                    InteractiveInputRow(
                      label: "Start Time",
                      value: DateFormat('MMMM d, y').format(_startDate),
                      trailing: _startTime.format(context),
                      onTapValue: () async {
                        final picked = await pickDate(
                          context,
                          initialDate: _startDate,
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      onTapTrailing: () async {
                        final picked = await pickTime(
                          context,
                          initialTime: _startTime,
                        );
                        if (picked != null) setState(() => _startTime = picked);
                      },
                    ),

                    InteractiveInputRow(
                      label: "End Time",
                      value: _endTime.format(context),
                      onTapValue: () async {
                        final picked = await pickTime(
                          context,
                          initialTime: _endTime,
                        );
                        if (picked != null) setState(() => _endTime = picked);
                      },
                    ),
                  ],

                  // 4. DEADLINE
                  InteractiveInputRow(
                    label: "Deadline",
                    value: DateFormat('MMMM d, y').format(_deadlineDate),
                    trailing: _deadlineTime.format(context),
                    onTapValue: () async {
                      final picked = await pickDate(
                        context,
                        initialDate: _deadlineDate,
                      );
                      if (picked != null)
                        setState(() => _deadlineDate = picked);
                    },
                    onTapTrailing: () async {
                      final picked = await pickTime(
                        context,
                        initialTime: _deadlineTime,
                      );
                      if (picked != null)
                        setState(() => _deadlineTime = picked);
                    },
                  ),

                  // 5. CATEGORY
                  InteractiveInputRow(
                    label: "Category",
                    value: _category,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => CategorySelector(
                        currentCategory: _category,
                        onCategorySelected: (val) =>
                            setState(() => _category = val),
                      ),
                    ),
                  ),

                  // 6. TAGS
                  InteractiveInputRow(
                    label: "Tags",
                    value: _selectedTags.isEmpty
                        ? "None"
                        : _selectedTags.join(", "),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => StatefulBuilder(
                        builder: (context, sheetSetState) => TagSelector(
                          selectedTags: _selectedTags,
                          availableTags: _tagsList,
                          onTagsChanged: (newList) {
                            setState(() => _selectedTags = newList);
                            sheetSetState(() {});
                          },
                          onTagAdded: (newTag) async {
                            await ref
                                .read(tagsProvider.notifier)
                                .addTag(newTag);
                            setState(() {
                              if (!_tagsList.contains(newTag))
                                _tagsList.add(newTag);
                            });
                            sheetSetState(() {});
                          },
                          onTagRemoved: (removedTag) async {
                            setState(() {
                              _tagsList = List<String>.from(_tagsList)
                                ..remove(removedTag);
                              _selectedTags = List<String>.from(_selectedTags)
                                ..remove(removedTag);
                            });
                            await ref
                                .read(tagsProvider.notifier)
                                .deleteTag(removedTag);
                            sheetSetState(() {});
                          },
                        ),
                      ),
                    ),
                  ),

                  // 7. ADVANCED OPTIONS (UPDATED)
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        'Advanced Options',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      initiallyExpanded: _advancedExpanded,
                      onExpansionChanged: (val) =>
                          setState(() => _advancedExpanded = val),
                      children: [
                        // --- REMIND ME ON (UPDATED TO OFFSETS) ---
                        // Replaced the Date/Time picker with a simple Offset Selector
                        // but kept the "InteractiveInputRow" style.
                        Opacity(
                          opacity: _hasReminder ? 1.0 : 0.4,
                          child: InteractiveInputRow(
                            label:
                                "Alerts", // Renamed from "Remind me on" to fit logic
                            value: _formatOffsets(), // e.g. "10m, 1h before"
                            // If reminders are on, open the sheet. If off, do nothing.
                            onTap: _hasReminder
                                ? () => _showOffsetSelector(context)
                                : null,
                          ),
                        ),

                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Auto-Reschedule',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.8),
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            "Allow AI to move this task if missed",
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          trailing: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _movableByAI,
                              activeTrackColor: colorScheme.primary,
                              onChanged: (v) =>
                                  setState(() => _movableByAI = v),
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Strict Mode',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.8),
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            "Ensure absolutely no overlaps",
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                          trailing: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _setNonConfliction,
                              activeTrackColor: colorScheme.primary,
                              onChanged: (v) =>
                                  setState(() => _setNonConfliction = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
