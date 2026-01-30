import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/selectors/pick_time.dart';
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';

class WorkHours extends StatefulWidget {
  const WorkHours({super.key});

  @override
  State<WorkHours> createState() => _WorkHoursState();
}

class _WorkHoursState extends State<WorkHours> {
  TimeOfDay _fromTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _toTime = const TimeOfDay(hour: 0, minute: 0);
  bool _isLoading = false;

  String _formatTimeLabel(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    return "$hour:$minute $period";
  }

  Future<void> _handleNavigation() async {
    setState(() => _isLoading = true);
    // Mimic the "Saving" process for UX feedback
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainCalendar()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access your established color scheme from themes.dart
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: colorScheme.surface, // 0xFFFFFFFF (Light) or 0xFF0C0C0C (Dark)
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
                      color: colorScheme.onSurface, // Black in Light, White in Dark
                    ),
                  ),
                  const SizedBox(height: 30),
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
        
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary, // 0xFFB0C8F5 (Light) or 0xFF333459 (Dark)
              ),
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
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: colorScheme.onSurface,
        ),
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface.withOpacity(0.85),
          ),
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
          backgroundColor: colorScheme.primary, 
          foregroundColor: colorScheme.onSurface,
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