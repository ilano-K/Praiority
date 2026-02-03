// File: lib/src/features/settings/presentation/pages/work_hours.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/pick_time.dart';
import 'package:flutter_app/features/settings/presentation/managers/settings_notfier.dart';
import 'package:flutter_app/features/settings/presentation/pages/mode_option.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkHours extends ConsumerStatefulWidget {
  // Flag to determine navigation path
  final bool isFromSidebar;
  
  const WorkHours({
    super.key, 
    this.isFromSidebar = false, // Defaults to false for onboarding
  });

  @override
  ConsumerState<WorkHours> createState() => _WorkHoursState();
}

class _WorkHoursState extends ConsumerState<WorkHours> {
  TimeOfDay _fromTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _toTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isLoading = false;

  String _formatTimeLabel(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  String _to24HourFormat(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Future<void> _handleNavigation({bool waitForSave = false}) async {
    // 1. VALIDATION
    if (waitForSave) {
      final int startMinutes = (_fromTime.hour * 60) + _fromTime.minute;
      final int endMinutes = (_toTime.hour * 60) + _toTime.minute;

      if (startMinutes == endMinutes) {
        _showError("Start time and End time cannot be the same.");
        return;
      }

      if (endMinutes < startMinutes) {
        _showError("End time must be later than Start time.");
        return;
      }
    }

    setState(() => _isLoading = true);

    // 2. SAVING
    if (waitForSave == true) {
      final String dbFrom = _to24HourFormat(_fromTime);
      final String dbTo = _to24HourFormat(_toTime);
      final settingsController = ref.read(settingsControllerProvider.notifier);
      await settingsController.saveSettings(dbFrom, dbTo);
    }

    // 3. SMART NAVIGATION
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    if (widget.isFromSidebar) {
      // If opened from Sidebar, just return to the Calendar
      Navigator.pop(context);
    } else {
      // If Onboarding, move to the next step
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ModeOption()),
      );
    }

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
          // Added a back button for sidebar users
          appBar: widget.isFromSidebar 
            ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,
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

  // --- Helpers ---
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