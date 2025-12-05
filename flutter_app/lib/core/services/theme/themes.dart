import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    // Background: D9D9D9
    surface: const Color(0xFFFFFFFF), 
    
    // Icon: 000000 (Black)
    onSurface: const Color(0xFF000000), 

    // Button: D5D6F5
    primary: const Color(0xFFB0C8F5), 
    
    // Calendar Cells: DFDFDF
    secondary: const Color(0xFFDFDFDF), 
    
    // Clicked: 9091C3
    tertiary: const Color(0xFF9091C3),

    // Add Task: F2F2F2 (Using this slot for your specific "Add Task" color)
    inversePrimary: const Color(0xFFF2F2F2),
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    // Background: 0C0C0C
    surface: const Color(0xFF0C0C0C), 

    // Icon: FFFFFF (White)
    onSurface: const Color(0xFFFFFFFF), 

    // Button: 333459
    primary: const Color(0xFF333459), 

    // Calendar Cells: 3A3A3A
    secondary: const Color(0xFF3A3A3A), 

    // Clicked: 333459 (Same as button in your dark palette)
    tertiary: const Color(0xFF333459),

    // Add Task: 2D2D2D
    inversePrimary: const Color(0xFF2D2D2D),
  ),
);