// File: lib/features/calendar/presentation/widgets/add_birthday_sheet.dart
// Purpose: UI sheet for adding birthday events; simplifies pre-filled fields.
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';
import 'package:intl/intl.dart';

// Import switching sheets

// Required Imports for Header
import 'color_selector.dart';
import 'add_header_sheet.dart'; // <--- NEW IMPORT

class AddBirthdaySheet extends StatefulWidget {
  final Task? task; // <--- ADDED: Data pocket for editing
  const AddBirthdaySheet({super.key, this.task}); // <--- UPDATED constructor

  @override
  State<AddBirthdaySheet> createState() => _AddBirthdaySheetState();
}

class _AddBirthdaySheetState extends State<AddBirthdaySheet> {
  // --- STATE VARIABLES ---
  String _selectedType = 'Birthday'; 
  
  // Birthday Specific Fields
  DateTime _birthdayDate = DateTime.now();
  String _location = "None"; 

  // --- SELECTED COLOR STATE ---
  CalendarColor _selectedColor = appEventColors[0];

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
    void initState() {
      super.initState();

      // 1. EDIT MODE: Pre-fill if an existing birthday was passed
      if (widget.task != null) {
        final b = widget.task!;
        _titleController.text = b.title;
        _descController.text = b.description ?? "";
        _birthdayDate = b.startTime ?? DateTime.now();
        _location = b.location ?? "None";
        // If location is stored in description or another field, map it here
      }
    }

    

// --- SAVE CALLBACK ---
  Task _handleSave() {
    // Birthdays are typically All Day events
    final startTime = startOfDay(_birthdayDate);
    final endTime = endOfDay(_birthdayDate);

    // 2. THE DECISION: Update vs Create
    if (widget.task != null) {
      // EDIT MODE: Preserves the original Task ID
      return widget.task!.copyWith(
        title: _titleController.text.trim().isEmpty ? "Birthday" : _titleController.text.trim(),
        description: _descController.text.trim(),
        isAllDay: true,
        location: _location,
      );
    } else {
      // CREATE MODE: Generates a new unique ID
      return Task.create(
        type: TaskType.birthday,
        title: _titleController.text.trim().isEmpty ? "Birthday" : _titleController.text.trim(),
        description: _descController.text.trim(),
        isAllDay: true,
        location: _location,
        status: TaskStatus.scheduled,
      );
    }
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

          // --- BIRTHDAY DETAILS LIST (Specific to Birthdays) ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. ARRANGE A DAY (Date Picker)
                  _buildInteractiveRow(
                    label: "Arrange a Day", 
                    value: DateFormat('MMMM d, y').format(_birthdayDate),
                    colors: colorScheme,
                    onTapValue: () => _pickDate(context, (date) => setState(() => _birthdayDate = date)),
                  ),

                  // 2. LOCATION
                  _buildInteractiveRow(
                    label: "Location", 
                    value: _location,
                    colors: colorScheme,
                    onTap: () => _showLocationDialog(context, colorScheme),
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
  Future<void> _pickDate(BuildContext context, Function(DateTime) onPicked) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), 
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: Theme.of(context).colorScheme),
        child: child!,
      ),
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
    VoidCallback? onTap, 
    VoidCallback? onTapValue, 
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
            ],
          ),
        ],
      ),
    );
  }
}