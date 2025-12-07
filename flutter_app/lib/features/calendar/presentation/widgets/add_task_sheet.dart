import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import your separate widgets
import 'priority_selector.dart';
import 'category_selector.dart';
import 'tag_selector.dart';
import 'color_selector.dart'; // Ensure this is imported for CalendarColor

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
  String _priority = "High";
  String _category = "None";
  String _tag = "None"; 
  
  // --- NEW: SELECTED COLOR STATE ---
  // Defaults to the first color (Default Purple) defined in color_selector.dart
  CalendarColor _selectedColor = appEventColors[0];

  // 1. MASTER TAG LIST
  List<String> _tagsList = ["Schoolwork", "Office", "Chore"];
  
  // Date/Time
  DateTime _deadlineDate = DateTime.now();
  TimeOfDay _deadlineTime = const TimeOfDay(hour: 23, minute: 59);
  DateTime _arrangeDate = DateTime.now();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 1. ACCESS THEME
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Resolve display color
    final Color displayColor = isDark ? _selectedColor.dark : _selectedColor.light;
    
    // 2. USE THEME COLOR
    final Color sheetBackground = colorScheme.inversePrimary; 

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
          // --- HEADER ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.close, size: 28, color: colorScheme.onSurface),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary, // Purple
                  foregroundColor: colorScheme.onSurface, // Text Color (Black)
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- TEXT FIELDS ---
          TextField(
            controller: _titleController,
            cursorColor: colorScheme.onSurface,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Add Title',
              border: InputBorder.none,
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w900),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          TextField(
            controller: _descController,
            cursorColor: colorScheme.onSurface,
            style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.8)),
            decoration: InputDecoration(
              hintText: 'Add Description',
              border: InputBorder.none,
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
              contentPadding: EdgeInsets.zero,
            ),
          ),

          const SizedBox(height: 25),

          // --- TYPE BUTTONS ---
          Row(
            children: [
              _buildTypeButton("Task", colorScheme),
              const SizedBox(width: 12),
              _buildTypeButton("Event", colorScheme),
              const SizedBox(width: 12),
              _buildTypeButton("Birthday", colorScheme),
            ],
          ),

          const SizedBox(height: 20),

          // --- COLOR PICKER (UPDATED) ---
          GestureDetector(
            onTap: () {
              // Open Color Selector
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => ColorSelector(
                  selectedColor: _selectedColor,
                  onColorSelected: (newColor) {
                    setState(() {
                      _selectedColor = newColor;
                    });
                  },
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: displayColor, // Shows the selected color
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _selectedColor.name, // <--- CHANGED: Shows Name instead of "Color"
                  style: TextStyle(
                    fontWeight: FontWeight.w500, 
                    fontSize: 16, 
                    color: colorScheme.onSurface
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Divider(thickness: 1, color: colorScheme.onSurface.withOpacity(0.1)),
          const SizedBox(height: 10),

          // --- SCROLLABLE SETTINGS LIST ---
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

                  // 3. DEADLINE
                  _buildInteractiveRow(
                    label: "Deadline", 
                    value: DateFormat('MMMM d, y').format(_deadlineDate),
                    trailing: _deadlineTime.format(context),
                    colors: colorScheme,
                    onTapValue: () => _pickDate(context, (date) => setState(() => _deadlineDate = date)),
                    onTapTrailing: () => _pickTime(context, (time) => setState(() => _deadlineTime = time)),
                  ),

                  // 4. ARRANGE A DAY
                  _buildInteractiveRow(
                    label: "Arrange a Day", 
                    value: DateFormat('MMMM d, y').format(_arrangeDate),
                    colors: colorScheme,
                    onTapValue: () => _pickDate(context, (date) => setState(() => _arrangeDate = date)),
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

  // --- LOGIC: Date & Time ---
  Future<void> _pickDate(BuildContext context, Function(DateTime) onPicked) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickTime(BuildContext context, Function(TimeOfDay) onPicked) async {
    final colorScheme = Theme.of(context).colorScheme;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: colorScheme.surface,
              dialHandColor: colorScheme.primary,
              dialTextColor: colorScheme.onSurface,
              dialBackgroundColor: colorScheme.surfaceVariant,
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected) ? Colors.white : colorScheme.onSurface),
              dayPeriodColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected) ? colorScheme.primary : Colors.transparent),
              dayPeriodBorderSide: BorderSide(color: colorScheme.primary),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onPicked(picked);
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

  // --- WIDGET HELPER: Type Button ---
  Widget _buildTypeButton(String label, ColorScheme colors) {
    bool isSelected = _selectedType == label;
    return GestureDetector(
      onTap: () {
        if (label == 'Event') {
          Navigator.pop(context); 
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddEventSheet(),
          );
        } else if (label == 'Birthday') {
          Navigator.pop(context);
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddBirthdaySheet(),
          );
        } else {
          setState(() => _selectedType = label);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          // Fill: Primary (Purple) if selected, Transparent if not
          color: isSelected ? colors.primary : Colors.transparent,
          
          // Border: Always Black (onSurface) whether selected or not
          border: Border.all(
            color: colors.onSurface, // Always Black Border
            width: 1.2
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.onSurface, // Always Black Text
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}