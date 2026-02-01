// File: lib/features/calendar/presentation/widgets/add_task_sheet.dart
// Purpose: Bottom sheet for creating/editing tasks with fields for title,
// time, tags, and category. Comments added only for clarity.
// File: lib/features/calendar/presentation/widgets/add_task_sheet.dart
// Purpose: UI sheet for creating or editing a task from the calendar.
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/pick_time.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/time_adjust.dart';
import 'package:intl/intl.dart';

// Import your separate widgets
import '../selectors/priority_selector.dart';
import '../selectors/category_selector.dart';
import '../selectors/tag_selector.dart';
import '../selectors/color_selector.dart'; // Ensure this is imported for CalendarColor

// IMPORTANT: Import the new Reusable Header (You must create this file)
import 'add_header_sheet.dart'; // Assuming the file is named '_add_sheet_header.dart'

// IMPORT THE EVENT & BIRTHDAY SHEETS

class AddTaskSheet extends ConsumerStatefulWidget {
  final Task? task;   
  const AddTaskSheet({super.key, this.task});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  // --- STATE VARIABLES ---
  String _selectedType = 'Task'; 
  bool _isSmartScheduleEnabled = true;

  // Dynamic Fields
  String _priority = "Medium";
  String _category = "None";
  List<String> _selectedTags = [];
  
  // --- SELECTED COLOR STATE ---
  CalendarColor _selectedColor = appEventColors[0];

  // 1. MASTER TAG LIST
  List<String> _tagsList = [];
  // --- COLLAPSIBLE AI OPTIONS ---
  bool _advancedExpanded = false;
  bool _movableByAI = false;
  bool _setNonConfliction = true;
  
  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _prefillFromTask(widget.task!);
    }

    // Fetch tags from repository
    ref.read(calendarRepositoryProvider).getAllTagNames().then((tags) {
      setState(() {
        _tagsList = tags.toList();
      });
    });
  }
  
  // Date/Time
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();

  // Endtime
  TimeOfDay _endTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 1))
  );

  // Deadline data and time
  DateTime _deadlineDate = DateTime.now();
  TimeOfDay _deadlineTime = const TimeOfDay(hour: 23, minute: 59);

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // map for data conversion
  final priorityMap = {
    "Low": TaskPriority.low,
    "Medium": TaskPriority.medium,
    "High": TaskPriority.high 
  };

  final categoryMap = {
    "Easy": TaskCategory.easy,
    "Average": TaskCategory.average,
    "Hard": TaskCategory.hard,
    "None" : TaskCategory.none
  };

  // --- HELPERS ---
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
    _endTime = TimeOfDay.fromDateTime(task.endTime ?? DateTime.now().add(const Duration(hours: 1)));
    _deadlineDate = task.deadline ?? DateTime.now();
    _deadlineTime = TimeOfDay.fromDateTime(task.deadline ?? DateTime.now());
    _selectedTags = task.tags;
    _priority = _enumToString(task.priority);
    _category = _enumToString(task.category);
    _movableByAI = task.isAiMovable;
    _setNonConfliction = task.isConflicting;

    if (task.colorValue != null) {
      _selectedColor = appEventColors.firstWhere(
        (c) => c.light.value == task.colorValue || c.dark.value == task.colorValue,
        orElse: () => appEventColors[0],
      );
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // --- SAVE CALLBACK ---
  Task createTaskSaveTemplate(bool isDark) {
    final colorValue = isDark ? _selectedColor.dark.value : _selectedColor.light.value;
    final title = _titleController.text.trim().isEmpty ? "Untitled Task" : _titleController.text.trim();
    final description = _descController.text.trim();
    final startDateTime = _combineDateAndTime(_startDate, _startTime);
    final endDateTime = _combineDateAndTime(_startDate, _endTime);
    final deadlineDateTime = _combineDateAndTime(_deadlineDate, _deadlineTime);

    final baseTask = Task.create(
      type: TaskType.task,
      title: title,
      description: description,
      startTime: startDateTime,
      endTime: endDateTime,
      deadline: deadlineDateTime,
      priority: priorityMap[_priority]!,
      category: categoryMap[_category]!,
      tags: _selectedTags, 
      status: TaskStatus.scheduled,
      colorValue: colorValue,
      isAllDay: false,
      recurrenceRule: null,
      isAiMovable: _movableByAI,
      isConflicting: _setNonConfliction
    );

    return widget.task != null ? widget.task!.copyWith(
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
      isAllDay: false,
      recurrenceRule: null,
      isAiMovable: baseTask.isAiMovable,
      isConflicting: baseTask.isConflicting
    ) : baseTask;
  }

  @override
  Widget build(BuildContext context) {
    // 1. ACCESS THEME
    final colorScheme = Theme.of(context).colorScheme;
    
    // 2. USE THEME COLOR
    final Color sheetBackground = colorScheme.inversePrimary; 

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // --- Create Header Data Object ---
    final headerData = HeaderData(
      selectedType: _selectedType,
      selectedColor: _selectedColor,
      titleController: _titleController,
      descController: _descController,
      // Update local state when user selects a different type/color
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
          
          // --- REPLACED: HEADER, TEXT FIELDS, TYPE BUTTONS, COLOR PICKER ---
          AddSheetHeader(data: headerData), 
          // ------------------------------------------------------------------
          
          // --- SCROLLABLE SETTINGS LIST (Task-specific content) ---
        // --- SCROLLABLE SETTINGS LIST ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. SMART SCHEDULE TOGGLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Smart Schedule", 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _isSmartScheduleEnabled,
                          activeThumbColor: Colors.white, 
                          activeTrackColor: colorScheme.primary, 
                          onChanged: (val) => setState(() => _isSmartScheduleEnabled = val),
                        ),
                      ),
                    ],
                  ),
                  
                  // Description Text (Only visible when enabled)
                  if (_isSmartScheduleEnabled) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "an AI-based system that schedules your tasks\nat the best time for you.",
                        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 10),


                  // 3. START & END TIME (HIDDEN IF SMART SCHEDULE IS ON)
                  if (!_isSmartScheduleEnabled) ...[
                    // START TIME
                    _buildInteractiveRow(
                      label: "Start Time", 
                      value: DateFormat('MMMM d, y').format(_startDate),
                      trailing: _startTime.format(context),
                      colors: colorScheme,
                      onTapValue: () async {
                        final picked = await pickDate(context, initialDate: _startDate);
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                            // (Recalculate deadline logic here if needed, keeping simple for snippet)
                          });
                        }
                      },
                      onTapTrailing: () async {
                        final picked = await pickTime(context);
                        if (picked != null) setState(() => _startTime = picked);
                      },
                    ),

                    // END TIME
                    _buildInteractiveRow(
                      label: "End Time", 
                      value: _endTime.format(context),
                      colors: colorScheme,
                      onTapValue: () async {
                        final picked = await pickTime(context, initialTime: _endTime);
                        if (picked != null) setState(() => _endTime = picked);
                      },
                    ),
                  ],

                  // 2. PRIORITY (ALWAYS VISIBLE)
                  // Label changes based on mode, but the selector is always there
                  _buildInteractiveRow(
                    label:  "Priority", 
                    value: _priority,
                    colors: colorScheme,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => PrioritySelector(
                          currentPriority: _priority,
                          onPrioritySelected: (val) => setState(() => _priority = val),
                        ),
                      );
                    }
                  ),

                  // 5. DEADLINE (ALWAYS VISIBLE)
                  _buildInteractiveRow(
                    label: "Deadline", 
                    value: DateFormat('MMMM d, y').format(_deadlineDate),
                    trailing: _deadlineTime.format(context),
                    colors: colorScheme,
                    onTapValue: () async {
                      final picked = await pickDate(context, initialDate: _deadlineDate);
                      if (picked != null) setState(() => _deadlineDate = picked);
                    },
                    onTapTrailing: () async {
                      final picked = await pickTime(context, initialTime: _deadlineTime);
                      if (picked != null) setState(() => _deadlineTime = picked);
                    },
                  ),

                   // 4. ADVANCED OPTIONS (ALWAYS VISIBLE)
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero, 
                      childrenPadding: EdgeInsets.zero,
                      title: Text(
                        'Advanced Options',
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: colorScheme.onSurface
                        ),
                      ),
                      initiallyExpanded: _advancedExpanded,
                      onExpansionChanged: (val) => setState(() => _advancedExpanded = val),
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          title: Text('Auto-Reschedule', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 15)),
                          subtitle: Text("Allow AI to move this task if missed", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                          trailing: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _movableByAI,
                              activeColor: Colors.white,
                              activeTrackColor: colorScheme.primary,
                              onChanged: (v) => setState(() => _movableByAI = v),
                            ),
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          title: Text('Strict Mode', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 15)),
                          subtitle: Text("Ensure absolutely no overlaps", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                          trailing: Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _setNonConfliction,
                              activeColor: Colors.white,
                              activeTrackColor: colorScheme.primary,
                              onChanged: (v) => setState(() => _setNonConfliction = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 6. CATEGORY (ALWAYS VISIBLE)
                  _buildInteractiveRow(
                    label: "Category", 
                    value: _category,
                    colors: colorScheme,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CategorySelector(
                          currentCategory: _category,
                          onCategorySelected: (val) => setState(() => _category = val),
                        ),
                      );
                    }
                  ),

                  // 7. TAGS (ALWAYS VISIBLE)
                  _buildInteractiveRow(
                    label: "Tags", 
                    value: _selectedTags.isEmpty ? "None" : _selectedTags.join(", "), 
                    colors: colorScheme,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter sheetSetState) {
                              return TagSelector(
                                selectedTags: _selectedTags,
                                availableTags: _tagsList, 
                                onTagsChanged: (newList) {
                                  setState(() => _selectedTags = newList);
                                  sheetSetState(() {}); 
                                },
                                onTagAdded: (newTag) async {
                                  setState(() {
                                    if (!_tagsList.contains(newTag)) _tagsList.add(newTag);
                                  });
                                  await ref.read(calendarControllerProvider.notifier).addTag(newTag);
                                  sheetSetState(() {});
                                },
                                onTagRemoved: (removedTag) async{
                                  setState(() {
                                    _tagsList = List<String>.from(_tagsList)..remove(removedTag);
                                    _selectedTags = List<String>.from(_selectedTags)..remove(removedTag);
                                  });
                                  await ref.read(calendarControllerProvider.notifier).deleteTag(removedTag);
                                  sheetSetState(() {});
                                },
                              );
                            },
                          );
                        }
                      );
                    }
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

  // --- WIDGET HELPER: Interactive Rows ---
  Widget _buildInteractiveRow({
    required String label, 
    required String value, 
    required ColorScheme colors,
    String? trailing,
    VoidCallback? onTap, 
    VoidCallback? onTapValue, 
    VoidCallback? onTapTrailing, 
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.onSurface)),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque, 
                  onTap: onTapValue ?? onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      value, 
                      style: TextStyle(fontSize: 15, color: colors.onSurface.withOpacity(0.8)),
                    ),
                  ),
                ),
              ),
              if (trailing != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapTrailing ?? onTap,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8), 
                    child: Text(
                      trailing, 
                      style: TextStyle(fontSize: 15, color: colors.onSurface.withOpacity(0.8)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}