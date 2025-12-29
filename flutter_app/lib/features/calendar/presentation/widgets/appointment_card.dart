// File: lib/features/calendar/presentation/widgets/appointment_card.dart
// Purpose: Small card widget that displays a single appointment/task in lists.
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
    // -------------------------------------------------------------------------
    // 1. CONFIGURATION (Easy to Edit)
    // -------------------------------------------------------------------------
    const double borderRadius = 6.0;
    const double leftBarWidth = 4.0;
    const double minHeightForDescription = 40.0; // Hide description if slot < 40px
    
    // 2. Resolve Colors
    final Color backgroundColor = _getThemeAwareColor(context, appointment.color);
    // Darken the background slightly for the accent bar
    final Color accentColor = HSLColor.fromColor(backgroundColor).withLightness(
      (HSLColor.fromColor(backgroundColor).lightness - 0.1).clamp(0.0, 1.0)
    ).toColor();
    
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      // Ensure the card fills the entire calendar slot provided by Syncfusion
      width: double.infinity, 
      height: double.infinity, 
      margin: const EdgeInsets.all(1), 
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        // Optional: Add subtle shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      // Clip behavior ensures the left accent bar respects the border radius
      clipBehavior: Clip.antiAlias, 
      
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 3. LEFT ACCENT BAR (Visual Flair)
          Container(
            width: leftBarWidth,
            color: accentColor,
          ),

          // 4. CONTENT AREA (Dynamic Layout)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Check how much height we actually have
                final bool showDescription = constraints.maxHeight > minHeightForDescription;
                final bool isVerySmall = constraints.maxHeight < 25.0;

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    8, 
                    isVerySmall ? 2 : 6, // Reduce top padding if super small
                    8, 
                    isVerySmall ? 2 : 6
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start, // Align to top
                    mainAxisSize: MainAxisSize.min, // Don't force stretch content vertically
                    children: [
                      // TITLE
                      Text(
                        appointment.subject,
                        style: TextStyle(
                          color: textColor, 
                          fontSize: isVerySmall ? 12 : 14, // Scale font if tiny
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // DESCRIPTION (Conditional)
                      if (showDescription && appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                        const SizedBox(height: 2), 
                        // Flexible lets it take available space but cut off if needed
                        Flexible( 
                          child: Text(
                            appointment.notes!,
                            style: TextStyle(
                              color: textColor.withOpacity(0.7), 
                              fontSize: 11,
                            ),
                            // Calculate max lines based on height approximately
                            maxLines: (constraints.maxHeight / 16).floor() - 1, 
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
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
      return Theme.of(context).colorScheme.primaryContainer;
    }
  }
}