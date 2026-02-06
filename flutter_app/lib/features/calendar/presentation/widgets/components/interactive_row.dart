// File: lib/features/calendar/presentation/widgets/components/interactive_input_row.dart
import 'package:flutter/material.dart';

class InteractiveInputRow extends StatelessWidget {
  final String label;
  final String value;
  final String? trailing; // Added for Task Times
  final VoidCallback? onTap;
  final VoidCallback? onTapValue;
  final VoidCallback? onTapTrailing; // Added for Task Times

  const InteractiveInputRow({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
    this.onTapValue,
    this.onTapTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          GestureDetector(
            onTap: onTap,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: colorScheme.onSurface
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Value & Trailing Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Main Value (e.g., Date)
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapValue ?? onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 15, 
                        color: colorScheme.onSurface.withOpacity(0.8)
                      ),
                    ),
                  ),
                ),
              ),
              // Trailing Value (e.g., Time)
              if (trailing != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapTrailing ?? onTap,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8), 
                    child: Text(
                      trailing!,
                      style: TextStyle(
                        fontSize: 15, 
                        color: colorScheme.onSurface.withOpacity(0.8)
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}