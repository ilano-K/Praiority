// File: lib/features/calendar/presentation/widgets/add_birthday_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/utils/repeat_to_rrule.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/interactive_row.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';
import 'package:intl/intl.dart';

// Required Imports for Header
import '../selectors/color_selector.dart';
import 'add_header_sheet.dart';

class AddBirthdaySheet extends StatefulWidget {
  final Task? task;
  const AddBirthdaySheet({super.key, this.task});

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

    if (widget.task != null) {
      _prefillFromBirthday(widget.task!);
    }
  }

  // --- HELPER ---
  void _prefillFromBirthday(Task birthday) {
    _titleController.text = birthday.title;
    _descController.text = birthday.description ?? "";
    _birthdayDate = birthday.startTime ?? DateTime.now();
    _location = birthday.location ?? "None";

    if (birthday.colorValue != null) {
      _selectedColor = appEventColors.firstWhere(
        (c) =>
            c.light.value == birthday.colorValue ||
            c.dark.value == birthday.colorValue,
        orElse: () => appEventColors[0],
      );
    }

    if (birthday.title == "Untitled Task" ||
        birthday.title == "Untitled Event" ||
        birthday.title == "Birthday") {
      _titleController.text = "";
    } else {
      _titleController.text = birthday.title;
    }
  }

  // --- SAVE CALLBACK ---
  Task _handleSave(bool isDark) {
    final colorValue = isDark
        ? _selectedColor.dark.value
        : _selectedColor.light.value;
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    final endOfDay = DateTime(
      _birthdayDate.year,
      _birthdayDate.month,
      _birthdayDate.day,
      23,
      59,
      59,
    );

    final baseTask = Task.create(
      type: TaskType.birthday,
      title: title,
      description: description,
      startTime: _birthdayDate, // Birthdays usually start on the selected date
      endTime: endOfDay,
      isAllDay: true,
      location: _location,
      status: TaskStatus.scheduled,
      colorValue: colorValue,
      recurrenceRule: repeatToRRule("Yearly"),
      isAiMovable: false,
      isConflicting: false,
      isSmartSchedule: false,
    );

    return widget.task != null
        ? widget.task!.copyWith(
            title: baseTask.title,
            description: baseTask.description,
            startTime: baseTask.startTime,
            endTime: baseTask.endTime,
            isAllDay: baseTask.isAllDay,
            location: baseTask.location,
            colorValue: baseTask.colorValue,
            recurrenceRule: baseTask.recurrenceRule,
            deadline: null,
            isAiMovable: baseTask.isAiMovable,
            isConflicting: baseTask.isConflicting,
            isSmartSchedule: baseTask.isSmartSchedule,
            status: baseTask.status,
          )
        : baseTask;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color sheetBackground = colorScheme.inversePrimary;

    final headerData = HeaderData(
      selectedType: _selectedType,
      selectedColor: _selectedColor,
      titleController: _titleController,
      descController: _descController,
      onTypeSelected: (type) => setState(() => _selectedType = type),
      onColorSelected: (color) => setState(() => _selectedColor = color),
      saveTemplate: () => _handleSave(isDark),
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
                  // 1. ARRANGE A DAY (Updated to use your separate pickDate)
                  InteractiveInputRow(
                    label: "Arrange a Day",
                    value: DateFormat('MMMM d, y').format(_birthdayDate),
                    onTapValue: () async {
                      final picked = await pickDate(
                        context,
                        initialDate: _birthdayDate,
                        firstDate: DateTime(1900), // Standard birthday range
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _birthdayDate = picked);
                      }
                    },
                  ),

                  // 2. LOCATION
                  InteractiveInputRow(
                    label: "Location",
                    value: _location,
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

  // --- LOGIC: Location Dialog ---
  void _showLocationDialog(BuildContext context, ColorScheme colorScheme) {
    TextEditingController locController = TextEditingController(
      text: _location == "None" ? "" : _location,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          "Set Location",
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: TextField(
          controller: locController,
          autofocus: true,
          style: TextStyle(color: colorScheme.onSurface),
          cursorColor: colorScheme.onSurface,
          decoration: InputDecoration(
            hintText: "Enter location",
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onSurface),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(
                () => _location = locController.text.isEmpty
                    ? "None"
                    : locController.text,
              );
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
}
