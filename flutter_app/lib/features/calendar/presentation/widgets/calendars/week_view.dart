import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SfCalendar(
          view: CalendarView.week,
          // Removes the default Syncfusion header (January, navigation arrows)
          headerHeight: 0, 
          // Match your design: Start week on Sunday
          firstDayOfWeek: 7, 
          
          // Styling the Time Slots
          timeSlotViewSettings: const TimeSlotViewSettings(
            timeIntervalHeight: 80, // Height of the gray blocks
            timeTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: Colors.black,
            ),
            // Customizing the vertical grid lines
            dayFormat: 'EEE', // "Thu"
          ),

          // Styling the Header (Dates/Days)
          viewHeaderStyle: const ViewHeaderStyle(
            dayTextStyle: TextStyle(color: Colors.grey, fontSize: 12),
            dateTextStyle: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16, 
              color: Colors.black
            ),
          ),

          // Customizing the Cell Appearance
          selectionDecoration: BoxDecoration(
          // Use 'color' for the background; transparent ensures the grey blocks show through
          color: Colors.grey, 
          // Matches your specific brand color or deepPurple as previously used
          border: Border.all(color: Colors.deepPurple, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
          
          // Background cell styling
          cellBorderColor: Colors.transparent, // We'll handle borders with the theme
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFDDE0FF),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}