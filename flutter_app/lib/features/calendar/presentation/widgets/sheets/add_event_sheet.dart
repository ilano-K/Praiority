// lib/features/calendar/presentation/widgets/sheets/add_event_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/calendar/presentation/utils/repeat_to_rrule.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_adjust.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/components/interactive_row.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/pick_time.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../selectors/tag_selector.dart';
import '../selectors/repeat_selector.dart'; 
import '../selectors/color_selector.dart'; 
import 'add_header_sheet.dart'; 

class AddEventSheet extends ConsumerStatefulWidget {
  final Task? task;
  const AddEventSheet({super.key, this.task});

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  // --- STATE VARIABLES ---
  String _selectedType = 'Event'; 
  bool _isAllDay = false; 
  
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  
  DateTime _endDate = DateTime.now();
  TimeOfDay _endTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 1))
  );

  String _repeat = "None";
  
  // --- CUSTOM RECURRENCE STATE ---
  int? _customInterval;
  String? _customUnit;
  Set<int>? _customDays;
  String? _customEndOption;
  DateTime? _customEndDate;
  int? _customCount;
  String? _monthlyType;

  String _location = "None"; 
  List<String> _selectedTags = [];
  CalendarColor _selectedColor = appEventColors[0];
  List<String> _tagsList = [];
  
  bool _movableByAI = true;
  bool _setNonConfliction = true;
  bool _hasManuallySetConflict = false;
  bool _hasReminder = true;
  DateTime _reminderDate = DateTime.now();
  TimeOfDay _reminderTime = TimeOfDay.now();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _prefillFromEvent(widget.task!);
    }
    ref.read(calendarRepositoryProvider).getAllTagNames().then((tags) {
      setState(() => _tagsList = tags.toList());
    });
  }

// lib/features/calendar/presentation/widgets/sheets/add_event_sheet.dart

  void _prefillFromEvent(Task event) {
    setState(() {
      _titleController.text = event.title;
      _descController.text = event.description ?? "";
      _isAllDay = event.isAllDay;
      _startDate = event.startTime ?? DateTime.now();
      _startTime = TimeOfDay.fromDateTime(event.startTime ?? DateTime.now());
      _endDate = event.endTime ?? DateTime.now();
      _endTime = TimeOfDay.fromDateTime(event.endTime ?? DateTime.now());
      _selectedTags = event.tags;
      _location = event.location ?? "None";
      _movableByAI = event.isAiMovable;
      _setNonConfliction = event.isConflicting;

      // ✅ FIXED: Parse the saved RRule back into the UI state
      _repeat = rruleToRepeat(event.recurrenceRule);

      if (event.colorValue != null) {
        _selectedColor = appEventColors.firstWhere(
          (c) => c.light.value == event.colorValue || c.dark.value == event.colorValue,
          orElse: () => appEventColors[0],
        );
      }
    });
  }

  // --- HELPER METHODS ---
  void _resetCustomFields() {
    _customInterval = null;
    _customUnit = null;
    _customDays = null;
    _customEndOption = null;
    _customEndDate = null;
    _customCount = null;
    _monthlyType = null;
  }

  String _getRepeatDisplayValue() {
    if (_repeat != "Custom") return _repeat;
    if (_customUnit == null) return "Custom";
    String unit = _customInterval == 1 ? _customUnit! : "${_customUnit}s";
    return "Every $_customInterval $unit";
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Task createTaskSaveTemplate(bool isDark) {
    final colorValue = isDark ? _selectedColor.dark.value : _selectedColor.light.value;
    final title = _titleController.text.trim().isEmpty ? "Untitled Event" : _titleController.text.trim();
    
    final DateTime startTime = _isAllDay ? startOfDay(_startDate) : _combineDateAndTime(_startDate, _startTime);
    final DateTime endTime = _isAllDay ? endOfDay(_startDate) : _combineDateAndTime(_endDate, _endTime);
    final DateTime startTimeForRule = _isAllDay ? startOfDay(_startDate) : _combineDateAndTime(_startDate, _startTime);

    final baseTask = Task.create(
      type: TaskType.event,
      title: title,
      description: _descController.text.trim(),
      startTime: startTime,
      endTime: endTime,
      deadline: null,
      isAllDay: _isAllDay,
      tags: _selectedTags, 
      location: _location,
      status: TaskStatus.scheduled,
      recurrenceRule: repeatToRRule(
        _repeat, 
        start: startTimeForRule,
        interval: _customInterval,
        unit: _customUnit,
        selectedDays: _customDays,
        endOption: _customEndOption,
        endDate: _customEndDate,
        occurrences: _customCount,
        monthlyType: _monthlyType,
      ),
      colorValue: colorValue,
      isAiMovable: _movableByAI,
      isConflicting: _setNonConfliction
    );

    return widget.task != null ? widget.task!.copyWith(
      title: baseTask.title,
      description: baseTask.description,
      startTime: baseTask.startTime,
      endTime: baseTask.endTime,
      deadline: baseTask.deadline,
      isAllDay: baseTask.isAllDay,
      isSmartSchedule: false,
      tags: baseTask.tags, 
      location: baseTask.location,
      recurrenceRule: baseTask.recurrenceRule,
      colorValue: baseTask.colorValue,
      isAiMovable: baseTask.isAiMovable,
      isConflicting: baseTask.isConflicting
    ) : baseTask;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color sheetBackground = colorScheme.inversePrimary; 
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
          AddSheetHeader(data: HeaderData(
            selectedType: _selectedType,
            selectedColor: _selectedColor,
            titleController: _titleController,
            descController: _descController,
            onTypeSelected: (type) => setState(() => _selectedType = type),
            onColorSelected: (color) => setState(() => _selectedColor = color),
            saveTemplate: () => createTaskSaveTemplate(isDark),
          )), 
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- REMINDERS ROW ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Reminders",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _hasReminder 
                                  ? "You'll get a reminder at the start time" 
                                  : "Reminders are turned off",
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

                  // --- ALL DAY SWITCH ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("All Day", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      Transform.scale(
                        scale: 0.8,
                        child: Switch(
                          value: _isAllDay,
                          activeTrackColor: colorScheme.primary,
                          onChanged: (val) => setState(() {
                            _isAllDay = val;
                            if(_isAllDay && !_hasManuallySetConflict) _setNonConfliction = false;
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // --- DATE/TIME PICKERS ---
                  if (_isAllDay) ...[
                    InteractiveInputRow(
                      label: "Date", 
                      value: DateFormat('MMMM d, y').format(_startDate),
                      onTapValue: () async {
                        final date = await pickDate(context, initialDate: _startDate);
                        if (date != null) setState(() => _startDate = date);
                      },
                    ),
                  ] else ...[
                    InteractiveInputRow(
                      label: "From", 
                      value: DateFormat('MMMM d, y').format(_startDate),
                      trailing: _startTime.format(context), 
                      onTapValue: () async {
                        final date = await pickDate(context, initialDate: _startDate);
                        if (date != null) setState(() => _startDate = date);
                      },
                      onTapTrailing: () async {
                        final time = await pickTime(context, initialTime: _startTime);
                        if (time != null) setState(() => _startTime = time);
                      },
                    ),
                    InteractiveInputRow(
                      label: "To", 
                      value: DateFormat('MMMM d, y').format(_endDate),
                      trailing: _endTime.format(context),
                      onTapValue: () async {
                        final date = await pickDate(context, initialDate: _endDate);
                        if (date != null) setState(() => _endDate = date);
                      },
                      onTapTrailing: () async {
                        final time = await pickTime(context, initialTime: _endTime);
                        if (time != null) setState(() => _endTime = time);
                      },
                    ),
                  ],

                  // --- REPEAT ROW ---

                  InteractiveInputRow(
                    label: "Repeat",
                    value: _getRepeatDisplayValue(), 
                    onTapValue: () async {
                      final dynamic result = await showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => RepeatSelector(
                          currentRepeat: _repeat,
                          onRepeatSelected: (val) {}, // Still required by the class signature
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          if (result is String) {
                            // Handle "Daily", "Weekly", etc.
                            _repeat = result;
                            _resetCustomFields(); // Clear custom data if a preset is picked
                          } else if (result is Map<String, dynamic>) {
                            // Handle the Map returned by CustomSelector
                            _repeat = "Custom";
                            _customInterval = result['interval'];
                            _customUnit = result['unit'];
                            _customDays = result['days'];
                            _customEndOption = result['endOption'];
                            _customEndDate = result['endDate'];
                            _customCount = result['occurrences'];
                            _monthlyType = result['monthlyType'];
                          }
                        });
                      }
                    },
                  ),

                  // --- LOCATION & TAGS ---
                  InteractiveInputRow(
                    label: "Location", value: _location,
                    onTapValue: () => _showLocationDialog(context, colorScheme),
                  ),
                  InteractiveInputRow(
                    label: "Tags", value: _selectedTags.isEmpty ? "None" : _selectedTags.join(", "),
                    onTapValue: () => _showTagSelector(context),
                  ),

                  // --- ADVANCED OPTIONS ---
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        'Advanced Options',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                      children: [
                        Opacity(
                          opacity: _hasReminder ? 1.0 : 0.4,
                          child: InteractiveInputRow(
                            label: "Remind me on",
                            value: DateFormat('MMMM d, y').format(_reminderDate),
                            trailing: _reminderTime.format(context),
                            onTapValue: _hasReminder ? () async {
                              final date = await pickDate(context, initialDate: _reminderDate);
                              if (date != null) setState(() => _reminderDate = date);
                            } : null,
                            onTapTrailing: _hasReminder ? () async {
                              final time = await pickTime(context, initialTime: _reminderTime);
                              if (time != null) setState(() => _reminderTime = time);
                            } : null,
                          ),
                        ),
                        _buildSwitchTile(
                          'Auto-Reschedule',
                          "Allow AI to move this task if missed",
                          _movableByAI,
                          (v) => setState(() => _movableByAI = v),
                          colorScheme,
                        ),
                        _buildSwitchTile(
                          'Strict Mode',
                          "Ensure absolutely no overlaps",
                          _setNonConfliction,
                          (v) => setState(() {
                            _setNonConfliction = v;
                            _hasManuallySetConflict = true;
                          }),
                          colorScheme,
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

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged, ColorScheme colors) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: colors.onSurface.withOpacity(0.8), fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: colors.onSurface.withOpacity(0.5), fontSize: 12)),
      trailing: Transform.scale(scale: 0.8, child: Switch(value: value, activeTrackColor: colors.primary, onChanged: onChanged)),
    );
  }

  void _showTagSelector(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (ctx, sheetSetState) => TagSelector(
          selectedTags: _selectedTags, availableTags: _tagsList,
          onTagsChanged: (newList) { setState(() => _selectedTags = newList); sheetSetState(() {}); },
          onTagAdded: (newTag) { setState(() { if (!_tagsList.contains(newTag)) _tagsList.add(newTag); }); sheetSetState(() {}); },
          onTagRemoved: (removedTag) { setState(() { _tagsList.remove(removedTag); _selectedTags.remove(removedTag); }); sheetSetState(() {}); },
        ),
      ),
    );
  }

  void _showLocationDialog(BuildContext context, ColorScheme colorScheme) {
    TextEditingController locController = TextEditingController(text: _location == "None" ? "" : _location);
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text("Set Location", style: TextStyle(color: colorScheme.onSurface)),
      content: TextField(controller: locController, autofocus: true, decoration: InputDecoration(hintText: "Enter location")),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        ElevatedButton(onPressed: () { setState(() => _location = locController.text.isEmpty ? "None" : locController.text); Navigator.pop(context); }, child: const Text("Set")),
      ],
    ));
  }
}