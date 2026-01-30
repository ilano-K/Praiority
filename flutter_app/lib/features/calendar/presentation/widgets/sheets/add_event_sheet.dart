// File: lib/features/calendar/presentation/widgets/add_event_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'package:flutter_app/features/calendar/domain/entities/task.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/calendar/presentation/utils/repeat_to_rrule.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_adjust.dart';
import 'package:flutter_app/features/calendar/presentation/utils/time_utils.dart';
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
  String _location = "None"; 
  List<String> _selectedTags = [];
  CalendarColor _selectedColor = appEventColors[0];
  List<String> _tagsList = [];
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _prefillFromEvent(widget.task!);
    }

    ref.read(calendarRepositoryProvider).getAllTagNames().then((tags) {
      setState(() {
        _tagsList = tags.toList();
      });
    });
  }

  void _prefillFromEvent(Task event) {
    _titleController.text = event.title;
    _descController.text = event.description ?? "";
    _isAllDay = event.isAllDay;
    _startDate = event.startTime ?? DateTime.now();
    _startTime = TimeOfDay.fromDateTime(event.startTime ?? DateTime.now());
    _endDate = event.endTime ?? DateTime.now();
    _endTime = TimeOfDay.fromDateTime(event.endTime ?? DateTime.now());
    _selectedTags = event.tags;
    _location = event.location ?? "None";
    _repeat = rruleToRepeat(event.recurrenceRule);

    if (event.colorValue != null) {
      _selectedColor = appEventColors.firstWhere(
        (c) => c.light.value == event.colorValue || c.dark.value == event.colorValue,
        orElse: () => appEventColors[0],
      );
    }
  }

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Task createTaskSaveTemplate(bool isDark) {
    final colorValue = isDark ? _selectedColor.dark.value : _selectedColor.light.value;
    final title = _titleController.text.trim().isEmpty ? "Untitled Event" : _titleController.text.trim();
    final description = _descController.text.trim();
    
    final DateTime startTime = _isAllDay 
        ? startOfDay(_startDate)
        : _combineDateAndTime(_startDate, _startTime);
        
    final DateTime endTime = _isAllDay
        ? endOfDay(_startDate)
        : _combineDateAndTime(_endDate, _endTime);

    final DateTime startTimeForRule = _isAllDay 
        ? startOfDay(_startDate) 
        : _combineDateAndTime(_startDate, _startTime);

    final baseTask = Task.create(
      type: TaskType.event,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      isAllDay: _isAllDay,
      tags: _selectedTags, 
      location: _location,
      status: TaskStatus.scheduled,
      recurrenceRule: repeatToRRule(_repeat, start: startTimeForRule),
      colorValue: colorValue,
    );

    return widget.task != null ? widget.task!.copyWith(
      title: baseTask.title,
      description: baseTask.description,
      startTime: baseTask.startTime,
      endTime: baseTask.endTime,
      isAllDay: baseTask.isAllDay,
      tags: baseTask.tags, 
      location: baseTask.location,
      recurrenceRule: baseTask.recurrenceRule,
      colorValue: baseTask.colorValue,
      deadline: null,
    ) : baseTask;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color sheetBackground = colorScheme.inversePrimary; 
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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

                  if (_isAllDay) ...[
                    _buildInteractiveRow(
                      label: "Date", 
                      value: DateFormat('MMMM d, y').format(_startDate),
                      colors: colorScheme,
                      onTapValue: () async {
                        final date = await pickDate(context, initialDate: _startDate);
                        if (date != null) setState(() => _startDate = date);
                      },
                    ),
                  ] else ...[
                    _buildInteractiveRow(
                      label: "From", 
                      value: DateFormat('MMMM d, y').format(_startDate),
                      trailing: _startTime.format(context), 
                      colors: colorScheme,
                      onTapValue: () async {
                        final date = await pickDate(context, initialDate: _startDate);
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                            final reference = DateTime(date.year, date.month, date.day, _endTime.hour, _endTime.minute);
                            final currentEnd = DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);
                            final adjusted = ensureNotBefore(currentEnd, reference, bumpIfBefore: const Duration(hours: 0));
                            _endDate = DateTime(adjusted.year, adjusted.month, adjusted.day);
                            _endTime = TimeOfDay(hour: adjusted.hour, minute: adjusted.minute);
                          });
                        }
                      },
                      onTapTrailing: () async {
                        final time = await pickTime(context, initialTime: _startTime);
                        if (time != null) {
                          setState(() {
                            _startTime = time;
                            final newStart = DateTime(_startDate.year, _startDate.month, _startDate.day, _startTime.hour, _startTime.minute);
                            final currentEnd = DateTime(_endDate.year, _endDate.month, _endDate.day, _endTime.hour, _endTime.minute);
                            final adjusted = ensureNotBefore(currentEnd, newStart, bumpIfBefore: const Duration(hours: 1));
                            _endDate = DateTime(adjusted.year, adjusted.month, adjusted.day);
                            _endTime = TimeOfDay(hour: adjusted.hour, minute: adjusted.minute);
                          });
                        }
                      },
                    ),
                    _buildInteractiveRow(
                      label: "To", 
                      value: DateFormat('MMMM d, y').format(_endDate),
                      trailing: _endTime.format(context),
                      colors: colorScheme,
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

                  _buildInteractiveRow(
                    label: "Location", 
                    value: _location,
                    colors: colorScheme,
                    onTap: () => _showLocationDialog(context, colorScheme),
                  ),

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
                          return StatefulBuilder(
                            builder: (BuildContext context, StateSetter sheetSetState) {
                              return TagSelector(
                                selectedTags: _selectedTags,
                                availableTags: _tagsList, 
                                onTagsChanged: (newList) {
                                  setState(() => _selectedTags = newList);
                                  sheetSetState(() {}); 
                                },
                                onTagAdded: (newTag) {
                                  setState(() {
                                    if (!_tagsList.contains(newTag)) {
                                      _tagsList.add(newTag);
                                    }
                                  });
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