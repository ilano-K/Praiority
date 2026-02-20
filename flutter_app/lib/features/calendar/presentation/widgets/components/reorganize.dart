import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/utils/date_time_utils.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/dialogs/app_dialog.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/date_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class Reschedule extends ConsumerStatefulWidget {
  const Reschedule({super.key});

  @override
  ConsumerState<Reschedule> createState() => _RescheduleState();
}

class _RescheduleState extends ConsumerState<Reschedule> {
  // State variable to track the selected date
  DateTime _targetDate = DateTime.now();

  final TextEditingController _instructionController = TextEditingController();
  // flag used to show a loader and prevent multiple taps
  bool _isLoading = false;

  @override
  void dispose(){
    _instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final content = Container(
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
            "Reorganize Schedule",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            "Optimize your schedule with AI.",
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          
          // --- TARGET DATE ROW (Clickable) ---
          InkWell(
            onTap: () async {
              if (_isLoading) return;
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
                hintText: "e.g., Prioritize deep work in the mornings and leave afternoons for workouts...",
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
              onPressed: _isLoading ? null : () async {
                setState(() => _isLoading = true);
                final instruction = _instructionController.text.trim();
                final calendarController = ref.read(calendarControllerProvider.notifier);
                print("instruction: $instruction");
                try{
                  final targetDateOnly = dateOnly(_targetDate);
                  await calendarController.reorganizeTask(targetDateOnly, instruction.isEmpty ? null : instruction);
                }catch(e){
                    if (context.mounted) {
                      AppDialogs.showWarning(
                        context, 
                        title: "Error", 
                        message: "An unexpected error occurred"
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isLoading = false);
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
                "Reorganize",
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

    // Added PopScope here to prevent closing while loading
    return PopScope(
      canPop: !_isLoading, 
      child: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoading,
            child: content,
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.transparent, 
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}