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
  final DateTime? initialDate; 

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
    _endTime = TimeOfDay.fromDateTime(task.endTime ?? DateTime.now().add(const Duration(hours: 1)));
    _deadlineDate = task.deadline ?? DateTime.now();
    _deadlineTime = TimeOfDay.fromDateTime(task.deadline ?? DateTime.now());
    _selectedTags = task.tags;
    _priority = _enumToString(task.priority);
    _category = _enumToString(task.category);
    _movableByAI = task.isAiMovable;
    _setNonConfliction = task.isConflicting;

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
        (c) => c.light.value == task.colorValue || c.dark.value == task.colorValue,
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
    final colorValue = isDark ? _selectedColor.dark.value : _selectedColor.light.value;
    final title = _titleController.text.trim().isEmpty ? "Untitled Task" : _titleController.text.trim();
    
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
      isAiMovable: baseTask.isAiMovable,
      isConflicting: baseTask.isConflicting,
      reminderOffsets: baseTask.reminderOffsets, // Update offsets
    ) : baseTask;
  }

  // --- NEW SELECTOR SHEET ---
  // --- UPDATED SELECTOR SHEET ---
  void _showOffsetSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // 1. Define Standard Presets
    final standardPresets = [
      const Duration(minutes: 0),
      const Duration(minutes: 10),
      const Duration(minutes: 30),
      const Duration(hours: 1),
      const Duration(days: 1),
    ];

    // 2. MERGE: Combine presets with any custom offsets the user has already selected.
    // We use a Set to avoid duplicates (e.g., if 10m is selected, don't show it twice).
    final allOptions = {...standardPresets, ..._selectedOffsets}.toList();
    
    // 3. SORT: Sort them by duration (0m -> 10m -> 45m -> 1h) so the UI looks clean.
    allOptions.sort();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Alerts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const SizedBox(height: 10),
                
                // 4. BUILD LIST DYNAMICALLY
                ...allOptions.map((offset) {
                  final isSelected = _selectedOffsets.contains(offset);
                  
                  // Generate label
                  String label;
                  if (offset.inMinutes == 0) label = "At time of event";
                  else if (offset.inMinutes < 60) label = "${offset.inMinutes} minutes before";
                  else if (offset.inHours < 24) label = "${offset.inHours} hour${offset.inHours > 1 ? 's' : ''}${offset.inMinutes % 60 != 0 ? ' ${offset.inMinutes % 60}m' : ''} before";
                  else label = "${offset.inDays} day${offset.inDays > 1 ? 's' : ''} before";

                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(label),
                    activeColor: colorScheme.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    onChanged: (val) {
                      setSheetState(() {
                        if (val == true) {
                          _selectedOffsets.add(offset);
                        } else {
                          _selectedOffsets.remove(offset);
                        }
                      });
                      setState(() {}); // Update the parent text field immediately
                    },
                  );
                }),

                const Divider(),

                ListTile(
                  leading: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.primary),
                  title: const Text("Custom duration..."),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  onTap: () async {
                    // 1. Close the Bottom Sheet
                    Navigator.pop(context); 
                    
                    // 2. Open the Dialog (and wait for it to finish)
                    await _pickCustomDuration(context); 
                    
                    // 3. Re-open the Bottom Sheet (if the screen is still valid)
                    if (mounted) _showOffsetSelector(context); 
                  },
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          );
        }
      ),
    );
  }

  // --- HELPER 1: PICK CUSTOM DURATION (e.g. 45 mins) ---
  // --- HELPER 1: PICK CUSTOM DURATION ---
  // --- HELPER 1: PICK CUSTOM DURATION (Standard Dialog) ---
  Future<void> _pickCustomDuration(BuildContext context) async {
    int hours = 0;
    int minutes = 15;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Remind me..."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("How long before the task starts?"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hours Input
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      autofocus: true,
                      initialValue: "0",
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(labelText: "Hours", border: OutlineInputBorder()),
                      onChanged: (val) => hours = int.tryParse(val) ?? 0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(":", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                  ),
                  // Minutes Input
                  SizedBox(
                    width: 70,
                    child: TextFormField(
                      initialValue: "15",
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(labelText: "Mins", border: OutlineInputBorder()),
                      onChanged: (val) => minutes = int.tryParse(val) ?? 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final duration = Duration(hours: hours, minutes: minutes);
                if (duration.inMinutes > 0) {
                  setState(() {
                    if (!_selectedOffsets.contains(duration)) {
                      _selectedOffsets.add(duration);
                    }
                  });
                }
                Navigator.pop(ctx); // ✅ JUST POP. Don't call _showOffsetSelector here.
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }
  // --- HELPER 2: PICK SPECIFIC DATE/TIME ---
  Future<void> _pickSpecificTime(BuildContext context) async {
    // 1. Pick Date
    final date = await pickDate(context, initialDate: _startDate); // Use your existing picker
    if (date == null) return;

    // 2. Pick Time
    final time = await pickTime(context, initialTime: _startTime); // Use your existing picker
    if (time == null) return;

    // 3. Calculate Offset
    final pickedDateTime = _combineDateAndTime(date, time);
    final taskStart = _combineDateAndTime(_startDate, _startTime);

    if (pickedDateTime.isAfter(taskStart)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reminder must be before the task starts!")),
      );
      return;
    }

    final offset = taskStart.difference(pickedDateTime);

    setState(() {
      if (!_selectedOffsets.contains(offset)) {
        _selectedOffsets.add(offset);
      }
    });
    
    // Re-open sheet
    _showOffsetSelector(context);
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
                            Text("Reminders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                            const SizedBox(height: 4),
                            Text(
                              _hasReminder ? "You'll get a notification" : "Reminders are turned off",
                              style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          value: _hasReminder,
                          activeTrackColor: colorScheme.primary,
                          onChanged: (val) => setState(() => _hasReminder = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

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

                  // 3. PRIORITY
                  InteractiveInputRow(
                    label: "Priority", value: _priority,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => PrioritySelector(
                        currentPriority: _priority,
                        onPrioritySelected: (val) => setState(() => _priority = val),
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
                        final picked = await pickDate(context, initialDate: _startDate);
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      onTapTrailing: () async {
                        final picked = await pickTime(context, initialTime: _startTime); 
                        if (picked != null) setState(() => _startTime = picked);
                      },
                    ),
                    
                    InteractiveInputRow(
                      label: "End Time", 
                      value: _endTime.format(context),
                      onTapValue: () async {
                        final picked = await pickTime(context, initialTime: _endTime); 
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
                    label: "Category", value: _category,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => CategorySelector(
                        currentCategory: _category,
                        onCategorySelected: (val) => setState(() => _category = val),
                      ),
                    ),
                  ),

                  // 6. TAGS
                  InteractiveInputRow(
                    label: "Tags", value: _selectedTags.isEmpty ? "None" : _selectedTags.join(", "), 
                    onTap: () => showModalBottomSheet(
                      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                      builder: (ctx) => StatefulBuilder(
                        builder: (context, sheetSetState) => TagSelector(
                          selectedTags: _selectedTags, availableTags: _tagsList,
                          onTagsChanged: (newList) { setState(() => _selectedTags = newList); sheetSetState(() {}); },
                          onTagAdded: (newTag) async {
                            await ref.read(tagsProvider.notifier).addTag(newTag);
                            setState(() { if (!_tagsList.contains(newTag)) _tagsList.add(newTag); });
                            sheetSetState(() {});
                          },
                          onTagRemoved: (removedTag) async {
                            setState(() {
                              _tagsList = List<String>.from(_tagsList)..remove(removedTag);
                              _selectedTags = List<String>.from(_selectedTags)..remove(removedTag);
                            });
                            await ref.read(tagsProvider.notifier).deleteTag(removedTag);
                            sheetSetState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // 7. ADVANCED OPTIONS (UPDATED)
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero, 
                      title: Text('Advanced Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      initiallyExpanded: _advancedExpanded,
                      onExpansionChanged: (val) => setState(() => _advancedExpanded = val),
                      children: [
                        // --- REMIND ME ON (UPDATED TO OFFSETS) ---
                        // Replaced the Date/Time picker with a simple Offset Selector
                        // but kept the "InteractiveInputRow" style.
                        Opacity(
                          opacity: _hasReminder ? 1.0 : 0.4,
                          child: InteractiveInputRow(
                            label: "Alerts", // Renamed from "Remind me on" to fit logic
                            value: _formatOffsets(), // e.g. "10m, 1h before"
                            // If reminders are on, open the sheet. If off, do nothing.
                            onTap: _hasReminder ? () => _showOffsetSelector(context) : null,
                          ),
                        ),
                        
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Auto-Reschedule', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 15)),
                          subtitle: Text("Allow AI to move this task if missed", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                          trailing: Transform.scale(scale: 0.8, child: Switch(value: _movableByAI, activeTrackColor: colorScheme.primary, onChanged: (v) => setState(() => _movableByAI = v))),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Strict Mode', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 15)),
                          subtitle: Text("Ensure absolutely no overlaps", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                          trailing: Transform.scale(scale: 0.8, child: Switch(value: _setNonConfliction, activeTrackColor: colorScheme.primary, onChanged: (v) => setState(() => _setNonConfliction = v))),
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