// File: lib/features/calendar/presentation/widgets/appointment_card.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../selectors/color_selector.dart'; 

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 6.0;
    const double leftBarWidth = 4.0;
    const double minHeightForDescription = 40.0; 
    
    // --- DETECTION FOR COMPLETION ---
    final bool isCompleted = appointment.notes?.startsWith("[COMPLETED]") ?? false;
    final String displayNotes = isCompleted 
        ? appointment.notes!.replaceFirst("[COMPLETED]", "") 
        : (appointment.notes ?? "");

    final Color backgroundColor = _getThemeAwareColor(context, appointment.color);
    final Color accentColor = HSLColor.fromColor(backgroundColor).withLightness(
      (HSLColor.fromColor(backgroundColor).lightness - 0.1).clamp(0.0, 1.0)
    ).toColor();
    
    // --- LIGHTEN TEXT COLOR FOR COMPLETED TASKS ---
    final Color baseTextColor = Theme.of(context).colorScheme.onSurface;
    final Color textColor = isCompleted ? baseTextColor.withOpacity(0.4) : baseTextColor;

    return Container(
      width: double.infinity, 
      height: double.infinity, 
      margin: const EdgeInsets.all(1), 
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, 
      
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: leftBarWidth,
            color: isCompleted ? accentColor.withOpacity(0.4) : accentColor,
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool showDescription = constraints.maxHeight > minHeightForDescription;
                final bool isVerySmall = constraints.maxHeight < 25.0;

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    8, 
                    isVerySmall ? 2 : 6,
                    8, 
                    isVerySmall ? 2 : 6
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TITLE
                      Text(
                        appointment.subject,
                        style: TextStyle(
                          color: textColor, 
                          fontSize: isVerySmall ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          // --- UPDATED: Strikethrough and Italic ---
                          decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                          fontStyle: isCompleted ? FontStyle.italic : FontStyle.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // DESCRIPTION
                      if (showDescription && displayNotes.isNotEmpty) ...[
                        const SizedBox(height: 2), 
                        Flexible( 
                          child: Text(
                            displayNotes,
                            style: TextStyle(
                              color: textColor.withOpacity(0.7), 
                              fontSize: 11,
                              // --- UPDATED: Strikethrough and Italic ---
                              decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                              fontStyle: isCompleted ? FontStyle.italic : FontStyle.normal,
                            ),
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

  Color _getThemeAwareColor(BuildContext context, Color storedColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    try {
      final themeColor = appEventColors.firstWhere(
        (c) => c.light.value == storedColor.value || c.dark.value == storedColor.value,
      );
      return isDark ? themeColor.dark : themeColor.light;
    } catch (e) {
      if (storedColor != Colors.transparent) {
        return storedColor;
      }
      return Theme.of(context).colorScheme.primaryContainer;
    }
  }
}