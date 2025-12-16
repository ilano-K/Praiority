import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/date_picker.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/pick_time.dart';
import 'package:intl/intl.dart';

// Import your separate widgets
import 'priority_selector.dart';
import 'category_selector.dart';
import 'tag_selector.dart';
import 'color_selector.dart'; // Ensure this is imported for CalendarColor

// IMPORTANT: Import the new Reusable Header (You must create this file)
import 'add_header_sheet.dart'; // Assuming the file is named '_add_sheet_header.dart'

// IMPORT THE EVENT & BIRTHDAY SHEETS
import 'add_event_sheet.dart'; 
import 'add_birthday_sheet.dart'; 

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  // --- STATE VARIABLES ---
  String _selectedType = 'Task'; 
  bool _isSmartScheduleEnabled = true;

  // Dynamic Fields
  String _priority = "Medium";
  String _category = "None";
  String _tag = "None"; 
  
  // --- SELECTED COLOR STATE ---
  CalendarColor _selectedColor = appEventColors[0];

  // 1. MASTER TAG LIST
  List<String> _tagsList = ["Schoolwork", "Office", "Chore"];// i need to fix this
  
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
  Task createTaskSaveTemplate() {
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

    final template = Task.create(
      title: _titleController.text.trim().isEmpty
        ? "New Task"
        : _titleController.text.trim(),
      description: _descController.text.trim(),
      isSmartSchedule: _isSmartScheduleEnabled,
      priority: priorityMap[_priority]!,
      startTime: startTime,
      endTime: endTime,
      deadline: deadline,
      category: categoryMap[_category]!,
      tags: _tag
    );

    return template;
  }

  @override
  Widget build(BuildContext context) {
    // 1. ACCESS THEME
    final colorScheme = Theme.of(context).colorScheme;
    
    // 2. USE THEME COLOR
    final Color sheetBackground = colorScheme.inversePrimary; 

    // --- Create Header Data Object ---
    final headerData = HeaderData(
      selectedType: _selectedType,
      selectedColor: _selectedColor,
      titleController: _titleController,
      descController: _descController,
      // Update local state when user selects a different type/color
      onTypeSelected: (type) => setState(() => _selectedType = type),
      onColorSelected: (color) => setState(() => _selectedColor = color),
      saveTemplate: createTaskSaveTemplate,
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
                          activeColor: Colors.white, 
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
                  ] else 
                    const SizedBox(height: 10),
                  
                  // 3. START TIME
                  _buildInteractiveRow(
                    label: "Start Time", 
                    value: DateFormat('MMMM d, y').format(_startDate),
                    trailing: _startTime.format(context),
                    colors: colorScheme,
                    onTapValue: () async {
                      final picked = await pickDate(
                        context,
                        initialDate: _startDate,
                      );
                      if (picked != null) {
                        setState(() => _startDate = picked);
                      }
                    },
                    onTapTrailing: () async {
                      final picked = await pickTime(context);
                      if (picked != null) {
                        setState(() => _startTime = picked);
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
                    value: _tag, 
                    colors: colorScheme,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => TagSelector(
                          currentTag: _tag,
                          availableTags: _tagsList,
                          onTagSelected: (val) => setState(() => _tag = val),
                          onTagAdded: (newTag) => setState(() => _tagsList.add(newTag)),
                          onTagRemoved: (removedTag) {
                            setState(() {
                              _tagsList.remove(removedTag);
                              if (_tag == removedTag) _tag = "None";
                            });
                            Navigator.pop(context); 
                          },
                        ),
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