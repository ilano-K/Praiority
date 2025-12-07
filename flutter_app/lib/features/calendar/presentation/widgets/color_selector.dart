import 'package:flutter/material.dart';

// 1. Model to hold the pair of colors (Light & Dark)
class CalendarColor {
  final String name;
  final Color light;
  final Color dark;

  const CalendarColor(this.name, this.light, this.dark);
}

// 2. The Data List (Extracted from your images)
const List<CalendarColor> appEventColors = [
  // Default (Purple Theme - Default 2)
  CalendarColor("Default", Color(0xFFD5D6F5), Color(0xFF333459)),
  
  // Solar Ember
  CalendarColor("Solar Ember", Color(0xFFF5A89A), Color(0xFFE74C36)),
  
  // Citrus Glow
  CalendarColor("Citrus Glow", Color(0xFFF7B38F), Color(0xFFE36B3D)),
  
  // Golden Haze
  CalendarColor("Golden Haze", Color(0xFFF7E7A4), Color(0xFFEBBB55)),
  
  // Verdant Pine
  CalendarColor("Verdant Pine", Color(0xFF8FCEAC), Color(0xFF438A5E)),
  
  // Meadow Mist
  CalendarColor("Meadow Mist", Color(0xFFA4E4C4), Color(0xFF5FB67F)),
  
  // Azure Crest
  CalendarColor("Azure Crest", Color(0xFFA7D5F7), Color(0xFF509BD4)),
  
  // Cool Periwave
  CalendarColor("Cool Periwave", Color(0xFFC2C4F2), Color(0xFF787BC8)),
  
  // Twilight Lilac
  CalendarColor("Twilight Lilac", Color(0xFFC5C8E1), Color(0xFF8991C2)),
  
  // Orchid Bloom
  CalendarColor("Orchid Bloom", Color(0xFFD9B3E8), Color(0xFFA85ABD)),
  
  // Coral Drift
  CalendarColor("Coral Drift", Color(0xFFF1C1B9), Color(0xFFD68479)),
  
  // Stone Alloy
  CalendarColor("Stone Alloy", Color(0xFFD3D3D3), Color(0xFF808080)),
];

class ColorSelector extends StatelessWidget {
  final CalendarColor selectedColor;
  final ValueChanged<CalendarColor> onColorSelected;

  const ColorSelector({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Check brightness to decide which color variant to show
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Limit height so it doesn't take full screen
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select Color",
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface
            ),
          ),
          const SizedBox(height: 20),
          
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 colors per row
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: appEventColors.length,
              itemBuilder: (context, index) {
                final item = appEventColors[index];
                // Resolve color based on mode
                final displayColor = isDark ? item.dark : item.light;
                final isSelected = item.name == selectedColor.name;

                return GestureDetector(
                  onTap: () {
                    onColorSelected(item);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: displayColor,
                      shape: BoxShape.circle,
                      // Add a ring if selected
                      border: isSelected 
                        ? Border.all(color: colorScheme.onSurface, width: 2) 
                        : null,
                    ),
                    // Checkmark in center if selected
                    child: isSelected 
                      ? Icon(
                          Icons.check, 
                          color: isDark ? Colors.white : Colors.black,
                          size: 20,
                        )
                      : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}