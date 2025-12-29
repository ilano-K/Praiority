// File: lib/features/calendar/presentation/widgets/add_event_sheet.dart
// Purpose: Bottom sheet UI for creating calendar events (non-task items).
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:intl/intl.dart';

// Import your separate widgets
import 'tag_selector.dart';
import 'repeat_selector.dart'; 
import 'color_selector.dart'; // <--- Required for CalendarColor

// IMPORTANT: Import the new Reusable Header
import 'add_header_sheet.dart'; // <--- NEW IMPORT

// IMPORTANT: Import other sheets for switching
import 'add_task_sheet.dart';
import 'add_birthday_sheet.dart'; 

class AddEventSheet extends StatefulWidget {
  const AddEventSheet({super.key});

  @override
  State<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<AddEventSheet> {
  // --- STATE VARIABLES ---
  String _selectedType = 'Event'; 
  
  // Event Specific Fields
  bool _isAllDay = false; // Toggles Date/Time display
  
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  
  DateTime _endDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);

  String _repeat = "None";
  String _location = "None"; 
  String _tag = "None";

  // --- SELECTED COLOR STATE ---
  CalendarColor _selectedColor = appEventColors[0];

  // MASTER TAG LIST (Persists new tags)
  List<String> _tagsList = ["Schoolwork", "Office", "Chore"];

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // --- SAVE CALLBACK ---
  Task _handleSave() {
    // Current save logic: just close the sheet (no controller implementation yet)
    // When Riverpod is added, this method will contain the logic to call ref.read(calendarControllerProvider.notifier).addEvent(...)
    return Task(id: "1", title: "asdfasd");
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
      saveTemplate: _handleSave,
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

          // --- EVENT DETAILS LIST ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. ALL DAY TOGGLE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("All Day", 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _isAllDay,
                          activeColor: Colors.white,
                          activeTrackColor: colorScheme.primary,
                          onChanged: (val) => setState(() => _isAllDay = val),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),

                  // 2. DYNAMIC DATE/TIME ROWS
                  if (_isAllDay) ...[
                    // --- ALL DAY MODE: Show Single Date ---
                    _buildInteractiveRow(
                      label: "Date", 
                      value: DateFormat('MMMM d, y').format(_startDate),
                      colors: colorScheme,
                      onTapValue: () => _pickDate(context, _startDate, (date) => setState(() => _startDate = date)),
                    ),
                  ] else ...[
                    // --- NORMAL MODE: Show From/To with Time ---
                    _buildInteractiveRow(
                      label: "From", 
                      value: DateFormat('MMMM d, y').format(_startDate),
                      trailing: _startTime.format(context), 
                      colors: colorScheme,
                      onTapValue: () => _pickDate(context, _startDate, (date) => setState(() => _startDate = date)),
                      onTapTrailing: () => _pickTime(context, _startTime, (time) => setState(() => _startTime = time)),
                    ),
                    _buildInteractiveRow(
                      label: "To", 
                      value: DateFormat('MMMM d, y').format(_endDate),
                      trailing: _endTime.format(context),
                      colors: colorScheme,
                      onTapValue: () => _pickDate(context, _endDate, (date) => setState(() => _endDate = date)),
                      onTapTrailing: () => _pickTime(context, _endTime, (time) => setState(() => _endTime = time)),
                    ),
                  ],

                  // 3. REPEAT
                  _buildInteractiveRow(
                    label: "Repeat",
                    value: _repeat,
                    colors: colorScheme,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => RepeatSelector(
                          currentRepeat: _repeat,
                          onRepeatSelected: (val) => setState(() => _repeat = val),
                        ),
                      );
                    },
                  ),

                  // 4. LOCATION
                  _buildInteractiveRow(
                    label: "Location", 
                    value: _location,
                    colors: colorScheme,
                    onTap: () => _showLocationDialog(context, colorScheme),
                  ),

                  // 5. TAGS
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
                          onTagRemoved: (tagToRemove) {
                            setState(() {
                              _tagsList.remove(tagToRemove);
                              if (_tag == tagToRemove) _tag = "None";
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

  // --- LOGIC: Date Picker ---
  Future<void> _pickDate(BuildContext context, DateTime initial, Function(DateTime) onPicked) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  // --- LOGIC: Time Picker ---
  Future<void> _pickTime(BuildContext context, TimeOfDay initial, Function(TimeOfDay) onPicked) async {
    final colorScheme = Theme.of(context).colorScheme;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
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

  // --- LOGIC: Location Dialog ---
  void _showLocationDialog(BuildContext context, ColorScheme colorScheme) {
    TextEditingController locController = TextEditingController(text: _location == "None" ? "" : _location);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text("Set Location", style: TextStyle(color: colorScheme.onSurface)),
        content: TextField(
          controller: locController,
          autofocus: true,
          style: TextStyle(color: colorScheme.onSurface),
          cursorColor: colorScheme.onSurface, 
          decoration: InputDecoration(
            hintText: "Enter location",
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface)), 
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.5))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: colorScheme.onSurface)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _location = locController.text.isEmpty ? "None" : locController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text("Set"),
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