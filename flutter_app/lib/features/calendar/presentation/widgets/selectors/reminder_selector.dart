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
              children: [
                Text("Alerts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const SizedBox(height: 10),

                ...allOptions.map((offset) {
                  final isSelected = currentSelection.contains(offset);
                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(_formatDuration(offset)),
                    activeColor: colorScheme.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    onChanged: (val) => toggleSelection(offset, val),
                  );
                }),

                const Divider(),

                // --- CUSTOM DURATION ---
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: colorScheme.primary),
                  title: const Text("Custom duration..."),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  onTap: () async {
                    Navigator.pop(innerContext); 
                    
                    await _pickCustomDuration(parentContext, (newDuration) {
                      if (!currentSelection.contains(newDuration)) {
                         // 1. Update Parent
                         onChanged([...currentSelection, newDuration]);
                         // 2. ✅ Update Local List (CRITICAL for re-opening)
                         currentSelection.add(newDuration);
                      }
                    });

                    if (parentContext.mounted) {
                      // Now we pass the UPDATED list to the new sheet
                      show(parentContext: parentContext, selectedOffsets: currentSelection, taskStartTime: taskStartTime, onChanged: onChanged);
                    }
                  },
                ),

                // --- SPECIFIC TIME ---
                ListTile(
                  leading: Icon(Icons.calendar_today_outlined, color: colorScheme.primary),
                  title: const Text("Pick specific time..."),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  onTap: () async {
                    Navigator.pop(innerContext); 

                    await _pickSpecificTime(parentContext, taskStartTime, (newDuration) {
                       if (!currentSelection.contains(newDuration)) {
                         onChanged([...currentSelection, newDuration]);
                         // 2. ✅ Update Local List here too
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

  // ... (Keep helpers _formatDuration, _pickCustomDuration, _pickSpecificTime exactly as they were) ...
  static String _formatDuration(Duration offset) {
    if (offset.inMinutes == 0) return "At time of event";
    if (offset.inMinutes < 60) return "${offset.inMinutes} minutes before";
    if (offset.inHours < 24) return "${offset.inHours} hour${offset.inHours > 1 ? 's' : ''}${offset.inMinutes % 60 != 0 ? ' ${offset.inMinutes % 60}m' : ''} before";
    return "${offset.inDays} day${offset.inDays > 1 ? 's' : ''} before";
  }

  static Future<void> _pickCustomDuration(BuildContext context, ValueChanged<Duration> onPicked) async {
    int hours = 0;
    int minutes = 15;

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Remind me..."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("How long before the task starts?"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNumberInput("Hours", "0", (val) => hours = int.tryParse(val) ?? 0),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text(":", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
                  _buildNumberInput("Mins", "15", (val) => minutes = int.tryParse(val) ?? 0),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                final duration = Duration(hours: hours, minutes: minutes);
                if (duration.inMinutes > 0) onPicked(duration);
                Navigator.pop(ctx);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildNumberInput(String label, String init, ValueChanged<String> onChanged) {
    return SizedBox(
      width: 70,
      child: TextFormField(
        autofocus: label == "Hours",
        initialValue: init,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
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