// File: lib/src/features/settings/presentation/pages/work_hours.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/pick_time.dart';
import 'package:flutter_app/features/settings/presentation/pages/mode_option.dart'; // Import the next step

class WorkHours extends StatefulWidget {
  const WorkHours({super.key});

  @override
  State<WorkHours> createState() => _WorkHoursState();
}

class _WorkHoursState extends State<WorkHours> {
  // Storing TimeOfDay to work with your custom pickTime function
  TimeOfDay _fromTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _toTime = const TimeOfDay(hour: 0, minute: 0);
  bool _isLoading = false;

  // Formats time to a readable 12-hour format with AM/PM (e.g., "09:00 AM")
  String _formatTimeLabel(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  // --- NAVIGATION LOGIC: Move to ModeOption next ---
  Future<void> _handleNavigation() async {
    setState(() => _isLoading = true);
    
    // Brief delay to provide "Saving" visual feedback
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ModeOption()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accessing your themes.dart color scheme reactively
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: colorScheme.surface, // Reactive: White (Light) or 0x0C0C0C (Dark)
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- TITLE ---
                  Text(
                    "Work Hours",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface, // Black (Light) or White (Dark)
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- DESCRIPTION ---
                  Text(
                    "Please specify your preferred working hours. These will be used to optimize your smart scheduling.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // --- FROM SECTION ---
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

                  // --- TO SECTION ---
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

                  // --- ACTION BUTTONS ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          text: "Save",
                          colorScheme: colorScheme,
                          onPressed: _isLoading ? null : _handleNavigation,
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
        
        // --- LOADING OVERLAY ---
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary, // B0C8F5 (Light) or 333459 (Dark)
              ),
            ),
          ),
      ],
    );
  }

  // Helper: Text Labels
  Widget _buildLabel(String text, ColorScheme colorScheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  // Helper: Time Input Fields
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface.withOpacity(0.85),
          ),
        ),
      ),
    );
  }

  // Helper: Primary Action Buttons
  Widget _buildActionButton({required String text, required VoidCallback? onPressed, required ColorScheme colorScheme}) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.onSurface,
          foregroundColor: colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}