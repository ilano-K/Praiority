import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/utils/date_time_utils.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/dialogs/app_dialog.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SmartSchedule extends ConsumerStatefulWidget {
  const SmartSchedule({super.key});

  @override
  ConsumerState<SmartSchedule> createState() => _SmartScheduleState();
}

class _SmartScheduleState extends ConsumerState<SmartSchedule> {
  // State variable to track the selected date
  DateTime _targetDate = DateTime.now();

  final TextEditingController _instructionController = TextEditingController();

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(height: 16),
          Text(
            "Smart Schedule",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            "Let the AI Create task for you!",
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          
          // --- TARGET DATE ROW (Clickable) ---
          InkWell(
            onTap: () async {
              final DateTime? picked = await pickDate(
                context, 
                initialDate: _targetDate,
              );
              if (picked != null && picked != _targetDate) {
                setState(() => _targetDate = picked);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Target Date",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  DateFormat('MMMM d, y').format(_targetDate),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          Divider(color: colorScheme.onSurface.withOpacity(0.1)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.onSurface.withOpacity(0.5)),
            ),
            child: TextField(
              controller: _instructionController,
              maxLines: 3,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "e.g., High priority: Fix the login bug today. Group it with other coding tasks and set the deadline for 5 PM.",
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () async {
                final instruction = _instructionController.text.trim();
                final calendarController = ref.read(calendarControllerProvider.notifier);
                
                try {
                  final targetDateOnly = dateOnly(_targetDate);
                  await calendarController.reorganizeTask(
                    targetDateOnly, 
                    instruction.isEmpty ? null : instruction
                  );
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    AppDialogs.showWarning(
                      context, 
                      title: "Error", 
                      message: "An unexpected error occurred",
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                "Optimize Schedule",
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold, 
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}