import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// IMPORTANT: Import your color selector list
import 'color_selector.dart'; 

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Resolve the Theme-aware Color
    final Color displayColor = _getThemeAwareColor(context, appointment.color);

    // 2. Determine text color based on the resolved background brightness
    //    We check 'displayColor' instead of 'appointment.color'
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      height: double.infinity, 
      margin: const EdgeInsets.all(1), 
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6), 
      decoration: BoxDecoration(
        color: displayColor, // <--- Use the dynamic color
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, 
        children: [
          // 1. TITLE
          Flexible(
            flex: 2, 
            child: Text(
              appointment.subject,
              style: TextStyle(
                color: textColor, 
                fontSize: 14, 
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // 2. DESCRIPTION
          if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: 2), 
            Flexible(
              flex: 1, 
              child: Text(
                appointment.notes!,
                style: TextStyle(
                  color: textColor.withOpacity(0.7), 
                  fontSize: 12,
                ),
                maxLines: 2, 
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Finds the matching [CalendarColor] pair and returns the correct one
  /// for the current Brightness (Light/Dark mode).
  Color _getThemeAwareColor(BuildContext context, Color storedColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    try {
      // 1. Try to find the color pair in our list
      //    We check if the stored color matches EITHER the light or dark version
      final themeColor = appEventColors.firstWhere(
        (c) => c.light.value == storedColor.value || c.dark.value == storedColor.value,
      );

      // 2. If found, return the correct variant for the CURRENT mode
      return isDark ? themeColor.dark : themeColor.light;
    } catch (e) {
      // 3. If not found (or default), return the stored color or primary fallback
      if (storedColor != Colors.transparent) {
        return storedColor;
      }
      return Theme.of(context).colorScheme.primary;
    }
  }
}