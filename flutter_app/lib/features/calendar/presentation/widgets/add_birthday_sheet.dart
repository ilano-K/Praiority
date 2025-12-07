import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Import switching sheets
import 'add_task_sheet.dart';
import 'add_event_sheet.dart';

// NEW IMPORT: Color Selector
import 'color_selector.dart';

class AddBirthdaySheet extends StatefulWidget {
  const AddBirthdaySheet({super.key});

  @override
  State<AddBirthdaySheet> createState() => _AddBirthdaySheetState();
}

class _AddBirthdaySheetState extends State<AddBirthdaySheet> {
  // --- STATE VARIABLES ---
  String _selectedType = 'Birthday'; 
  
  // Birthday Specific Fields
  DateTime _birthdayDate = DateTime.now();
  String _location = "None"; 

  // --- NEW: SELECTED COLOR STATE ---
  // Defaults to the first color (Default Purple)
  CalendarColor _selectedColor = appEventColors[0];

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
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.black, // Always Black Text
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

          // --- TITLE ---
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

          // --- DESCRIPTION ---
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
                    color: displayColor, // Shows selected color
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _selectedColor.name, // Shows selected name
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

          // --- BIRTHDAY DETAILS LIST ---
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
    VoidCallback? onTap, // Simple tap
    VoidCallback? onTapValue, // Specific tap
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

  // --- WIDGET HELPER: Type Button (Switching Logic) ---
  Widget _buildTypeButton(String label, ColorScheme colors) {
    bool isSelected = _selectedType == label;
    return GestureDetector(
      onTap: () {
        if (label == 'Task') {
          Navigator.pop(context); 
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTaskSheet(),
          );
        } else if (label == 'Event') {
          Navigator.pop(context); 
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddEventSheet(),
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
          
          // Border: ALWAYS Black (onSurface)
          border: Border.all(
            color: colors.onSurface, 
            width: 1.2
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.onSurface, // Text: Always Black
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}