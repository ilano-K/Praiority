// lib/features/calendar/presentation/widgets/selectors/repeat_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/domain/entities/enums.dart';
import 'custom_selector.dart';

class RepeatSelector extends StatelessWidget {
  final String currentRepeat;
  final ValueChanged<String> onRepeatSelected;

  // Variables passed from AddEventSheet to keep CustomSelector in sync
  final DateTime eventStartDate;
  final int? initialInterval;
  final String? initialUnit;
  final Set<int>? initialDays;
  final String? initialEndOption;
  final DateTime? initialEndDate;
  final int? initialOccurrences;
  final String? initialMonthlyType;
  
  // New parameter to customize options based on task type
  final TaskType taskType;

  const RepeatSelector({
    super.key,
    required this.currentRepeat,
    required this.onRepeatSelected,
    required this.eventStartDate,
    this.initialInterval,
    this.initialUnit,
    this.initialDays,
    this.initialEndOption,
    this.initialEndDate,
    this.initialOccurrences,
    this.initialMonthlyType,
    this.taskType = TaskType.task,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // For birthdays, only show Yearly and Custom options
    final isBirthday = taskType == TaskType.birthday;
    final allDayRepeatOptions = isBirthday 
        ? ['None', 'Yearly', 'Custom']
        : ['None', 'Daily', 'Weekly', 'Monthly', 'Yearly', 'Custom'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Repeat",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 15),
          ...allDayRepeatOptions.map((option) => _buildOption(context, option)),
          if (!isBirthday) const Divider(),
        ],
      ),
    );
  }

Widget _buildOption(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isSelected = currentRepeat == label;

    return ListTile(
      onTap: () async {
        if (label == "Custom") {
          // Open the CustomSelector as a bottom sheet
          final customData = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => CustomSelector(
              eventStartDate: eventStartDate,
              initialInterval: initialInterval,
              initialUnit: initialUnit,
              initialDays: initialDays,
              initialEndOption: initialEndOption,
              initialEndDate: initialEndDate,
              initialOccurrences: initialOccurrences,
              initialMonthlyType: initialMonthlyType,
              taskType: taskType,
            ),
          );

          if (customData != null && context.mounted) {
            Navigator.pop(context, customData);
          }
        } else {
          Navigator.pop(context, label);
        }
      },
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: colorScheme.primary) : null,
    );
  }
}