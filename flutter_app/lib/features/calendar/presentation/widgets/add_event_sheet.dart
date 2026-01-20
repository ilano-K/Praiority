// File: lib/features/calendar/presentation/widgets/add_event_sheet.dart
// Purpose: Bottom sheet UI for creating calendar events (non-task items).
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/providers/calendar_providers.dart';
import 'package:flutter_app/features/calendar/presentation/utils/repeat_to_rrule.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_adjust.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Import your separate widgets
import 'tag_selector.dart';
import 'repeat_selector.dart'; 
import 'color_selector.dart'; // <--- Required for CalendarColor

// IMPORTANT: Import the new Reusable Header
import 'add_header_sheet.dart'; // <--- NEW IMPORT

// IMPORTANT: Import other sheets for switching

class AddEventSheet extends ConsumerStatefulWidget {
  final Task? task; // <--- ADDED
  const AddEventSheet({super.key, this.task}); // <--- UPDATED

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  // --- STATE VARIABLES ---
  String _selectedType = 'Event'; 
  
  // Event Specific Fields
  bool _isAllDay = false; // Toggles Date/Time display
  
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 1))
  );

  String _repeat = "None";
  String _location = "None"; 
  List<String> _selectedTags = [];

  // --- SELECTED COLOR STATE ---
  CalendarColor _selectedColor = appEventColors[0];
  
  // MASTER TAG LIST (Persists new tags)
  List<String> _tagsList = [];
  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      final e = widget.task!;
      _titleController.text = e.title;
      _descController.text = e.description ?? "";
      _isAllDay = e.isAllDay;
      _startDate = e.startTime ?? DateTime.now();
      _startTime = TimeOfDay.fromDateTime(e.startTime ?? DateTime.now());
      _endDate = e.endTime ?? DateTime.now();
      _endTime = TimeOfDay.fromDateTime(e.endTime ?? DateTime.now());
      _selectedTags = e.tags;
      _location = e.location ?? "None";
      // _repeat would need rrule parsing logic here

      if (e.colorValue != null) {
        _selectedColor = appEventColors.firstWhere(
          (c) => c.light.value == e.colorValue || c.dark.value == e.colorValue,
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

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // --- SAVE CALLBACK ---
  Task createTaskSaveTemplate(bool isDark) {
    DateTime? startTime;
    DateTime? endTime;

    if(_isAllDay){
      startTime = startOfDay(_startDate);
      endTime = endOfDay(_startDate);
    } else {
      startTime = DateTime(
        _startDate.year,_startDate.month,_startDate.day,
        _startTime.hour,_startTime.minute,
      );
      endTime = DateTime(
        _endDate.year,_endDate.month,_endDate.day,
        _endTime.hour,_endTime.minute,
      );
    }
  

    DateTime startTimeForRule = _isAllDay 
        ? startOfDay(_startDate) 
        : DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);

    // 2. THE DECISION: Edit vs Create

    final int colorValue = isDark ? _selectedColor.dark.value : _selectedColor.light.value;

        if (widget.task != null) {
          // EDIT MODE: Preserves the Task ID
          return widget.task!.copyWith(
            title: _titleController.text.trim().isEmpty ? "Untitled Event" : _titleController.text.trim(),
            description: _descController.text.trim(),
            startTime: startTime,
            endTime: endTime,
            isAllDay: _isAllDay,
            tags: _selectedTags, 
            location: _location,
            recurrenceRule: repeatToRRule(_repeat, start: startTimeForRule),
            colorValue: colorValue,
          );
        } else {
          // CREATE MODE: Generates a new ID
          return Task.create(
            type: TaskType.event,
            title: _titleController.text.trim().isEmpty ? "New Event" : _titleController.text.trim(),
            description: _descController.text.trim(),
            startTime: startTime,
            endTime: endTime,
            isAllDay: _isAllDay,
            tags: _selectedTags, 
            location: _location,
            status: TaskStatus.scheduled,
            recurrenceRule: repeatToRRule(_repeat, start: startTimeForRule),
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
                          activeThumbColor: Colors.white,
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
                      onTapValue: () => _pickDate(context, _startDate, (date) {
                        // When start date changes, ensure end datetime is not
                        // before the new start. Preserve end time if possible.
                        setState(() {
                          _startDate = date;
                          final reference = DateTime(date.year, date.month, date.day, _endTime.hour, _endTime.minute);
                          final currentEnd = DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);
                          final adjusted = ensureNotBefore(currentEnd, reference, bumpIfBefore: const Duration(hours: 0));
                          _endDate = DateTime(adjusted.year, adjusted.month, adjusted.day);
                          _endTime = TimeOfDay(hour: adjusted.hour, minute: adjusted.minute);
                        });
                      }),
                      onTapTrailing: () => _pickTime(context, _startTime, (time) {
                        // When start time changes, ensure end is after start;
                        // if not, bump end by 1 hour after start.
                        setState(() {
                          _startTime = time;
                          final newStart = DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);
                          final currentEnd = DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);
                          final adjusted = ensureNotBefore(currentEnd, newStart, bumpIfBefore: const Duration(hours: 1));
                          _endDate = DateTime(adjusted.year, adjusted.month, adjusted.day);
                          _endTime = TimeOfDay(hour: adjusted.hour, minute: adjusted.minute);
                        });
                      }),
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
                                onTagAdded: (newTag) {
                                  setState(() {
                                    if (!_tagsList.contains(newTag)) {
                                      _tagsList.add(newTag);
                                    }
                                  });
                                  // Update the sheet so the new tag appears immediately
                                  sheetSetState(() {});
                                },
                                onTagRemoved: (removedTag) {
                                  setState(() {
                                    _tagsList = List<String>.from(_tagsList)..remove(removedTag);
                                    _selectedTags = List<String>.from(_selectedTags)..remove(removedTag);
                                  });
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
              dialBackgroundColor: colorScheme.surfaceContainerHighest,
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