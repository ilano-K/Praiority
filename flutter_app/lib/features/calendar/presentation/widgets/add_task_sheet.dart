// File: lib/features/calendar/presentation/widgets/add_task_sheet.dart
// Purpose: Bottom sheet for creating/editing tasks with fields for title,
// time, tags, and category. Comments added only for clarity.
// File: lib/features/calendar/presentation/widgets/add_task_sheet.dart
// Purpose: UI sheet for creating or editing a task from the calendar.
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/controllers/calendar_controller_providers.dart';
import 'package:flutter_app/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/date_picker.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/pick_time.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/time_adjust.dart';
import 'package:intl/intl.dart';

// Import your separate widgets
import 'priority_selector.dart';
import 'category_selector.dart';
import 'tag_selector.dart';
import 'color_selector.dart'; // Ensure this is imported for CalendarColor

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
  @override
  void initState() {
    super.initState();

    // --- PRE-FILL LOGIC ---
    if (widget.task != null) {
      final t = widget.task!;
      _titleController.text = t.title;
      _descController.text = t.description ?? "";
      _isSmartScheduleEnabled = t.isSmartSchedule;
      _startDate = t.startTime ?? DateTime.now();
      _startTime = TimeOfDay.fromDateTime(t.startTime ?? DateTime.now());
      _endTime = TimeOfDay.fromDateTime(t.endTime ?? DateTime.now().add(const Duration(hours: 1)));
      _deadlineDate = t.deadline ?? DateTime.now();
      _deadlineTime = TimeOfDay.fromDateTime(t.deadline ?? DateTime.now());
      _selectedTags = t.tags;

      
      // Map Enums to Strings
      _priority = t.priority.name[0].toUpperCase() + t.priority.name.substring(1);
      _category = t.category.name[0].toUpperCase() + t.category.name.substring(1);

     if (t.colorValue != null) {
        _selectedColor = appEventColors.firstWhere(
          (c) => c.light.value == t.colorValue || c.dark.value == t.colorValue,
          orElse: () => appEventColors[0],
        );
      }
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

  // --- SAVE CALLBACK ---
  Task createTaskSaveTemplate(bool isDark) {
    // Current save logic: just close the sheet (no controller implementation yet)
    DateTime deadline = DateTime(
        _deadlineDate.year,
        _deadlineDate.month,
        _deadlineDate.day,
        _deadlineTime.hour,
        _deadlineTime.minute,
    );
    DateTime startTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
    );

    DateTime endTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _endTime.hour,
        _endTime.minute,
    );
      // --- 2. THE DECISION (The part you are replacing) ---

      final int colorValue = isDark ? _selectedColor.dark.value : _selectedColor.light.value;

          if (widget.task != null) {
            debugPrint("This is the tags of the task: ${widget.task!.tags}");
            debugPrint("This is the tags of the task: ${widget.task!.title}");
            return widget.task!.copyWith(
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              startTime: startTime,
              endTime: endTime,
              deadline: deadline,
              priority: priorityMap[_priority]!,
              category: categoryMap[_category]!,
              tags: _selectedTags, // Ensure tags are captured
              colorValue: colorValue,
              isAllDay: false
            );
          } else {
            debugPrint("These are the tags $_selectedTags");
            return Task.create(
              type: TaskType.task,
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              startTime: startTime,
              endTime: endTime,
              deadline: deadline,
              priority: priorityMap[_priority]!,
              category: categoryMap[_category]!,
              tags: _selectedTags,
              status: TaskStatus.scheduled,
              colorValue: colorValue,
            );
          }
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. SMART SCHEDULE
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
                    const SizedBox(height: 20),

                    // Smart Priority
                    _buildInteractiveRow(
                      label: "Smart Priority", 
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
                  ] else ...[ 
                    // --- ONLY SHOW THESE IF SMART SCHEDULE IS DISABLED ---
                    const SizedBox(height: 10),
                  
                  // 3. START TIME
                  _buildInteractiveRow(
                    label: "Start Time", 
                    value: DateFormat('MMMM d, y').format(_startDate),
                    trailing: _startTime.format(context),
                    colors: colorScheme,
                    onTapValue: () async {
                      // Pick a new start date and ensure the deadline date/time
                      // does not end up before the new start. Use the shared
                      // helper so behavior is consistent across sheets.
                      final picked = await pickDate(
                        context,
                        initialDate: _startDate,
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;

                          // Compose reference = start date but at the current
                          // deadline time; we want the deadline to be at least
                          // this DateTime (preserving its time-of-day if possible).
                          final reference = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            _deadlineTime.hour,
                            _deadlineTime.minute,
                          );

                          final currentDeadline = DateTime(
                            _deadlineDate.year,
                            _deadlineDate.month,
                            _deadlineDate.day,
                            _deadlineTime.hour,
                            _deadlineTime.minute,
                          );

                          final adjusted = ensureNotBefore(currentDeadline, reference);
                          _deadlineDate = DateTime(adjusted.year, adjusted.month, adjusted.day);
                          _deadlineTime = TimeOfDay(hour: adjusted.hour, minute: adjusted.minute);
                        });
                      }
                    },
                    onTapTrailing: () async {
                      // Pick a new start time and ensure the deadline datetime
                      // remains after the new start; if it would be before,
                      // bump the deadline by one hour after the start.
                      final picked = await pickTime(context);
                      if (picked != null) {
                        setState(() {
                          _startTime = picked;

                          final newStartDT = DateTime(
                            _startDate.year,
                            _startDate.month,
                            _startDate.day,
                            _startTime.hour,
                            _startTime.minute,
                          );

                          final currentDeadlineDT = DateTime(
                            _deadlineDate.year,
                            _deadlineDate.month,
                            _deadlineDate.day,
                            _deadlineTime.hour,
                            _deadlineTime.minute,
                          );

                          final adjusted = ensureNotBefore(currentDeadlineDT, newStartDT, bumpIfBefore: const Duration(hours: 1));
                          _deadlineDate = DateTime(adjusted.year, adjusted.month, adjusted.day);
                          _deadlineTime = TimeOfDay(hour: adjusted.hour, minute: adjusted.minute);
                        });
                      }
                    },
                  ),

                  // 4. END TIME
                  _buildInteractiveRow(
                    label: "End Time", 
                    value: _endTime.format(context),
                    colors: colorScheme,
                    onTapValue: () async {
                      final picked = await pickTime(context, initialTime: _endTime);
                      if (picked != null) {
                        setState(() => _endTime = picked);
                      }
                    },
                  ),
                ],
                  // 3. DEADLINE
                  _buildInteractiveRow(
                    label: "Deadline", 
                    value: DateFormat('MMMM d, y').format(_deadlineDate),
                    trailing: _deadlineTime.format(context),
                    colors: colorScheme,
                    onTapValue: () async {
                      final picked = await pickDate(
                        context,
                        initialDate: _startDate,
                      );
                      if (picked != null) {
                        setState(() => _deadlineDate = picked);
                      }
                    },
                    onTapTrailing: () async {
                      final picked = await pickTime(context, initialTime: _deadlineTime);
                      if (picked != null) {
                        setState(() => _deadlineTime = picked);
                      }
                    },
                  ),

                  // 5. CATEGORY
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

                  // 6. TAGS
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
                          // StatefulBuilder allows the BottomSheet to refresh itself
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter sheetSetState) {
                              return TagSelector(
                                selectedTags: _selectedTags,
                                availableTags: _tagsList, 
                                onTagsChanged: (newList) {
                                  // Update BOTH the parent and the sheet
                                  setState(() => _selectedTags = newList);
                                  sheetSetState(() {}); 
                                },
                                onTagAdded: (newTag) async {
                                  setState(() {
                                    if (!_tagsList.contains(newTag)) {
                                      _tagsList.add(newTag);
                                    }
                                  });
                                  await ref.read(calendarControllerProvider.notifier).addTag(newTag);
                                  // Update the sheet so the new tag appears immediately
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