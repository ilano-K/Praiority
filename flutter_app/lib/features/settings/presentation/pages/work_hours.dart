// File: lib/src/features/settings/presentation/pages/work_hours.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/pick_time.dart';
import 'package:flutter_app/features/settings/presentation/managers/settings_notfier.dart';
import 'package:flutter_app/features/settings/presentation/pages/mode_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkHours extends ConsumerStatefulWidget {
  const WorkHours({super.key});

  @override
  ConsumerState<WorkHours> createState() => _WorkHoursState();
}

class _WorkHoursState extends ConsumerState<WorkHours> {
  // Defaults (9:00 AM to 5:00 PM)
  TimeOfDay _fromTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _toTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isLoading = false;

  // UI Format: "09:00 AM"
  String _formatTimeLabel(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  // ✅ DATABASE FORMAT: "14:05" (24-hour)
  String _to24HourFormat(TimeOfDay time) {
    // time.hour is already 0-23 in Flutter
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  // --- UPDATED NAVIGATION LOGIC ---
  Future<void> _handleNavigation({bool waitForSave = false}) async {
    
    // 1. VALIDATION CHECKER
    if (waitForSave) {
      // Convert both to "minutes from midnight" to compare them easily
      final int startMinutes = (_fromTime.hour * 60) + _fromTime.minute;
      final int endMinutes = (_toTime.hour * 60) + _toTime.minute;

      // Rule 1: Exact same time is invalid
      if (startMinutes == endMinutes) {
        _showError("Start time and End time cannot be the same.");
        return;
      }

      // Rule 2: End time must be AFTER Start time (Prevent "Reverse" or Overnight)
      // Example: Start 5 PM (1020 min) -> End 2 PM (840 min) = INVALID
      if (endMinutes < startMinutes) {
        _showError("End time must be later than Start time.");
        return;
      }
    }

    setState(() => _isLoading = true);

    // 2. SAVING
    if (waitForSave == true) {
      final String dbFrom = _to24HourFormat(_fromTime); // "09:00"
      final String dbTo = _to24HourFormat(_toTime);     // "17:00"

      print("[DEBUG]: SAVING... From: $dbFrom To: $dbTo");

      final settingsController = ref.read(settingsControllerProvider.notifier);
      await settingsController.saveSettings(dbFrom, dbTo);
    }

    // 3. NAVIGATION
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ModeOption()),
    );

    setState(() => _isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: colorScheme.surface, 
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Work Hours",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface, 
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Please specify your preferred working hours.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // --- FROM ---
                  _buildLabel("From", colorScheme),
                  const SizedBox(height: 10),
                  _buildTimeField(
                    timeLabel: _formatTimeLabel(_fromTime),
                    colorScheme: colorScheme,
                    onTap: () async {
                      final picked = await pickTime(context, initialTime: _fromTime);
                      if (picked != null) setState(() => _fromTime = picked);
                    },
                  ),

                  const SizedBox(height: 30),

                  // --- TO ---
                  _buildLabel("To", colorScheme),
                  const SizedBox(height: 10),
                  _buildTimeField(
                    timeLabel: _formatTimeLabel(_toTime),
                    colorScheme: colorScheme,
                    onTap: () async {
                      final picked = await pickTime(context, initialTime: _toTime);
                      if (picked != null) setState(() => _toTime = picked);
                    },
                  ),

                  const SizedBox(height: 60),

                  // --- BUTTONS ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          text: "Save",
                          colorScheme: colorScheme,
                          onPressed: _isLoading ? null : () => _handleNavigation(waitForSave: true),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildActionButton(
                          text: "Skip",
                          colorScheme: colorScheme,
                          onPressed: _isLoading ? null : _handleNavigation,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(String text, ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
      ),
    );
  }

  Widget _buildTimeField({required String timeLabel, required VoidCallback onTap, required ColorScheme colorScheme}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.onSurface, width: 1.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          timeLabel,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withOpacity(0.85)),
        ),
      ),
    );
  }

  Widget _buildActionButton({required String text, required VoidCallback? onPressed, required ColorScheme colorScheme}) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.onSurface,
          foregroundColor: colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}