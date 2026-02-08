// File: lib/features/calendar/presentation/widgets/add_task_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/interactive_row.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/pick_time.dart';
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
  final DateTime? initialDate; // Accepts the date from your DayView scroll

  const AddTaskSheet({
    super.key, 
    this.task, 
    this.initialDate,
  });

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

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Date & Time (Initialized as late because we set them in initState)
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late DateTime _deadlineDate;
  late TimeOfDay _deadlineTime;

  // Conversion Maps
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

  @override
  void initState() {
    super.initState();

    // 1. DYNAMIC INITIALIZATION
      final DateTime baseDate;
      
      if (widget.task != null) {
        // Priority 1: Use the time already saved in your DB
        baseDate = widget.task!.startTime ?? DateTime.now();
      } else if (widget.initialDate != null) {
        // Priority 2: Use the exact time of the grey block you clicked
        // SfCalendar passes the hour/minute of the slot automatically.
        baseDate = widget.initialDate!;
      } else {
        // Priority 3: Fallback to phone time if opened via FAB without a date
        baseDate = DateTime.now();
      }
      
      _startDate = baseDate;
      _startTime = TimeOfDay.fromDateTime(baseDate);
      
      // Set end time to 1 hour after the clicked slot
      _endTime = TimeOfDay.fromDateTime(
        baseDate.add(const Duration(hours: 1))
      );

      _deadlineDate = widget.task?.deadline ?? baseDate;
      _deadlineTime = const TimeOfDay(hour: 23, minute: 59);

      if (widget.task != null) {
        _prefillFromTask(widget.task!);
      }
  }

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

  Task createTaskSaveTemplate(bool isDark) {
    final colorValue = isDark ? _selectedColor.dark.value : _selectedColor.light.value;
    final title = _titleController.text.trim().isEmpty ? "Untitled Task" : _titleController.text.trim();
    final description = _descController.text.trim();

    var baseTask = Task.create(
      type:  TaskType.task,
      title: title,
      description: description,
        priority: priorityMap[_priority] ?? TaskPriority.none,
        category: categoryMap[_category] ?? TaskCategory.none,
      tags: _selectedTags,
      colorValue: colorValue,
      isAllDay: false,
      recurrenceRule: null,
      isAiMovable: _movableByAI,
      isConflicting: _setNonConfliction,
      isSmartSchedule: _isSmartScheduleEnabled,
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
    print("rebuilding now");
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

                  // 2. START & END TIME
                  if (!_isSmartScheduleEnabled) ...[
                    InteractiveInputRow(
                      label: "Start Time", 
                      value: DateFormat('MMMM d, y').format(_startDate),
                      trailing: _startTime.format(context),
                      onTapValue: () async {
                        final picked = await pickDate(context, initialDate: _startDate);
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      onTapTrailing: () async {
                        // Pass the CURRENTLY saved _startTime as the initial value
                        final picked = await pickTime(context, initialTime: _startTime); 
                        if (picked != null) setState(() => _startTime = picked);
                      },
                    ),

                    InteractiveInputRow(
                      label: "End Time", 
                      value: _endTime.format(context),
                      onTapValue: () async {
                        // Pass the CURRENTLY saved _endTime
                        final picked = await pickTime(context, initialTime: _endTime); 
                        if (picked != null) setState(() => _endTime = picked);
                      },
                    ),
                  ],

                  // 3. PRIORITY
                  InteractiveInputRow(
                    label: "Priority", 
                    value: _priority,
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

                  // 4. DEADLINE
                  InteractiveInputRow(
                    label: "Deadline", 
                    value: DateFormat('MMMM d, y').format(_deadlineDate),
                    trailing: _deadlineTime.format(context),
                    onTapValue: () async {
                      final picked = await pickDate(context, initialDate: _deadlineDate);
                      if (picked != null) setState(() => _deadlineDate = picked);
                    },
                    onTapTrailing: () async {
                      final picked = await pickTime(context, initialTime: _deadlineTime);
                      if (picked != null) setState(() => _deadlineTime = picked);
                    },
                  ),

                  // 5. CATEGORY
                  InteractiveInputRow(
                    label: "Category", 
                    value: _category,
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

                  // 6. TAGS
                  InteractiveInputRow(
                    label: "Tags", 
                    value: _selectedTags.isEmpty ? "None" : _selectedTags.join(", "), 
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
                                  await ref.read(tagsProvider.notifier).addTag(newTag);
                                  setState(() {
                                    if (!_tagsList.contains(newTag)) _tagsList.add(newTag);
                                  });
                                  sheetSetState(() {});
                                },
                                onTagRemoved: (removedTag) async{
                                  setState(() {
                                    _tagsList = List<String>.from(_tagsList)..remove(removedTag);
                                    _selectedTags = List<String>.from(_selectedTags)..remove(removedTag);
                                  });
                                  await ref.read(tagsProvider.notifier).deleteTag(removedTag);
                                  sheetSetState(() {});
                                },
                              );
                            },
                          );
                        }
                      );
                    }
                  ),
                  
                  // 7. ADVANCED OPTIONS
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero, 
                      childrenPadding: EdgeInsets.zero,
                      title: Text('Advanced Options',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      initiallyExpanded: _advancedExpanded,
                      onExpansionChanged: (val) => setState(() => _advancedExpanded = val),
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
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