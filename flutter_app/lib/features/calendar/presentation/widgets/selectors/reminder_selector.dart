import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/pick_time.dart';

class ReminderSelector {
  
  static Future<void> show({
    required BuildContext parentContext, 
    required List<Duration> selectedOffsets,
    required DateTime taskStartTime,
    required ValueChanged<List<Duration>> onChanged,
  }) async {
    final colorScheme = Theme.of(parentContext).colorScheme;

    // 1. Local copy for state management inside the sheet
    final List<Duration> currentSelection = List.from(selectedOffsets);

    final standardPresets = [
      const Duration(minutes: 0),
      const Duration(minutes: 10),
      const Duration(minutes: 30),
      const Duration(hours: 1),
      const Duration(days: 1),
    ];

    List<Duration> getAllOptions() {
      final merged = {...standardPresets, ...currentSelection}.toList();
      merged.sort();
      return merged;
    }

    await showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (innerContext, setSheetState) {
          
          void toggleSelection(Duration offset, bool? selected) {
            if (selected == true) {
              currentSelection.add(offset);
            } else {
              currentSelection.remove(offset);
            }
            onChanged(currentSelection); 
            setSheetState(() {}); 
          }

          final allOptions = getAllOptions();

          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // ALIGN LEFT
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                // ALIGN LEFT with padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Remind me", 
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold, 
                      color: colorScheme.onSurface 
                    )
                  ),
                ),
                const SizedBox(height: 10),

                ...allOptions.map((offset) {
                  final isSelected = currentSelection.contains(offset);
                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(
                      _formatDuration(offset),
                      style: TextStyle(color: colorScheme.onSurface), 
                    ),
                    activeColor: colorScheme.primary, // Kept at primary
                    checkColor: colorScheme.onPrimary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    onChanged: (val) => toggleSelection(offset, val),
                  );
                }),

                const Divider(),

                // --- CUSTOM DURATION ---
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: colorScheme.onSurface),
                  title: Text(
                    "Custom duration",
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  onTap: () async {
                    Navigator.pop(innerContext); 
                    
                    await _pickCustomDuration(parentContext, (newDuration) {
                      if (!currentSelection.contains(newDuration)) {
                          onChanged([...currentSelection, newDuration]);
                          currentSelection.add(newDuration);
                      }
                    });

                    if (parentContext.mounted) {
                      show(parentContext: parentContext, selectedOffsets: currentSelection, taskStartTime: taskStartTime, onChanged: onChanged);
                    }
                  },
                ),

                // --- SPECIFIC TIME ---
                ListTile(
                  leading: Icon(Icons.calendar_today_outlined, color: colorScheme.onSurface),
                  title: Text(
                    "Pick specific date",
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  onTap: () async {
                    Navigator.pop(innerContext); 

                    await _pickSpecificTime(parentContext, taskStartTime, (newDuration) {
                       if (!currentSelection.contains(newDuration)) {
                         onChanged([...currentSelection, newDuration]);
                         currentSelection.add(newDuration);
                       }
                    });

                    if (parentContext.mounted) {
                      show(parentContext: parentContext, selectedOffsets: currentSelection, taskStartTime: taskStartTime, onChanged: onChanged);
                    }
                  },
                ),
                SizedBox(height: MediaQuery.of(innerContext).padding.bottom),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _formatDuration(Duration offset) {
    if (offset.inMinutes == 0) return "At time of event";
    if (offset.inMinutes < 60) return "${offset.inMinutes} minutes before";
    if (offset.inHours < 24) return "${offset.inHours} hour${offset.inHours > 1 ? 's' : ''}${offset.inMinutes % 60 != 0 ? ' ${offset.inMinutes % 60}m' : ''} before";
    return "${offset.inDays} day${offset.inDays > 1 ? 's' : ''} before";
  }

  static Future<void> _pickCustomDuration(BuildContext context, ValueChanged<Duration> onPicked) async {
    int hours = 0;
    int minutes = 15;
    final colorScheme = Theme.of(context).colorScheme; 

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: Text(
            "Remind me...", 
            style: TextStyle(color: colorScheme.onSurface)
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "How long before the task starts?",
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNumberInput(context, "Hours", "0", (val) => hours = int.tryParse(val) ?? 0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10), 
                    child: Text(
                      ":", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 24,
                        color: colorScheme.onSurface
                      )
                    )
                  ),
                  _buildNumberInput(context, "Mins", "15", (val) => minutes = int.tryParse(val) ?? 0),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              // UPDATED: Changed from primary to onSurface
              child: Text("Cancel", style: TextStyle(color: colorScheme.onSurface))
            ),
            TextButton(
              onPressed: () {
                final duration = Duration(hours: hours, minutes: minutes);
                if (duration.inMinutes > 0) onPicked(duration);
                Navigator.pop(ctx);
              },
              // UPDATED: Changed from primary to onSurface
              child: Text("Add", style: TextStyle(color: colorScheme.onSurface)),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildNumberInput(BuildContext context, String label, String init, ValueChanged<String> onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 70,
      child: TextFormField(
        autofocus: label == "Hours",
        initialValue: init,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(color: colorScheme.onSurface), 
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
             // UPDATED: Changed from primary to onSurface
             borderSide: BorderSide(color: colorScheme.onSurface),
          ),
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  static Future<void> _pickSpecificTime(BuildContext context, DateTime taskStartTime, ValueChanged<Duration> onPicked) async {
    final date = await pickDate(context, initialDate: taskStartTime);
    if (date == null) return;

    final time = await pickTime(context, initialTime: TimeOfDay.fromDateTime(taskStartTime));
    if (time == null) return;

    final pickedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final cleanTaskStart = DateTime(taskStartTime.year, taskStartTime.month, taskStartTime.day, taskStartTime.hour, taskStartTime.minute);

    if (pickedDateTime.isAfter(cleanTaskStart)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reminder must be before the task starts!")));
      }
      return;
    }

    final offset = cleanTaskStart.difference(pickedDateTime);
    onPicked(offset);
  }
}