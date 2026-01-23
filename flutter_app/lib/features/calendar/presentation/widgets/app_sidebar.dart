// File: lib/features/calendar/presentation/widgets/app_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/pages/auth_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart'; // Required for the Enum
import '../../../../core/services/theme/theme_notifier.dart';

class AppSidebar extends ConsumerWidget {
  final Function(CalendarView) onViewSelected; // Callback for view switching

  const AppSidebar({super.key, required this.onViewSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: colorScheme.surface,
      width: MediaQuery.of(context).size.width * 0.75,
      child: SafeArea(
        child: Column(
          children: [
            // --- USER PROFILE SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.person, size: 70, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Juan Dela Cruz",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
                  ),
                  Text(
                    "juandelacruz@gmail.com",
                    style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.4)),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Divider(thickness: 1, color: colorScheme.onSurface.withOpacity(0.1)),
            ),

            // --- NAVIGATION LIST ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                children: [
                  _buildExpandableItem(
                    context, 
                    lightIcon: 'assets/icons/view.png', 
                    darkIcon: 'assets/icons/viewDark.png', 
                    label: "View",
                    isDark: isDark,
                  ),
                  _buildDrawerItem(
                    context, 
                    icon: Icons.access_time_outlined, 
                    label: "Working Hours",
                  ),
                  _buildDrawerItem(
                    context, 
                    icon: Icons.cloud_sync_outlined, 
                    label: "Cloud Sync",
                  ),
                  _buildDrawerItem(
                    context, 
                    icon: Icons.logout_outlined, 
                    label: "Log Out",
                    onTap: () {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => const AuthPage())
                      );
                    }
                  ),
                ],
              ),
            ),

            // --- THEME TOGGLE ---
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: _buildThemeToggle(context, ref, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String label, VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurface, size: 28),
      title: Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  Widget _buildExpandableItem(BuildContext context, {required String lightIcon, required String darkIcon, required String label, required bool isDark}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Image.asset(isDark ? darkIcon : lightIcon, width: 28, height: 28),
        title: Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
        iconColor: colorScheme.onSurface,
        collapsedIconColor: colorScheme.onSurface,
        childrenPadding: const EdgeInsets.only(left: 30),
        children: [
          _buildSubItem(context, "Month", 'assets/icons/month.png', 'assets/icons/monthDark.png', isDark, CalendarView.month),
          _buildSubItem(context, "Week", 'assets/icons/week.png', 'assets/icons/weekDark.png', isDark, CalendarView.week),
          _buildSubItem(context, "Day", 'assets/icons/day.png', 'assets/icons/dayDark.png', isDark, CalendarView.day),
        ],
      ),
    );
  }

  Widget _buildSubItem(BuildContext context, String label, String lightIcon, String darkIcon, bool isDark, CalendarView view) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Image.asset(isDark ? darkIcon : lightIcon, width: 24, height: 24),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
      onTap: () {
        onViewSelected(view); // Change the view
        Navigator.pop(context); // Close the drawer
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 80, height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildToggleSide(context, isActive: !isDark, icon: Icons.wb_sunny_outlined, 
            onTap: () => isDark ? ref.read(themeProvider.notifier).toggleTheme() : null),
          _buildToggleSide(context, isActive: isDark, icon: Icons.nightlight_outlined, 
            onTap: () => !isDark ? ref.read(themeProvider.notifier).toggleTheme() : null),
        ],
      ),
    );
  }

  Widget _buildToggleSide(BuildContext context, {required bool isActive, required IconData icon, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isActive ? colorScheme.primary.withOpacity(0.2) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: isActive ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.4)),
        ),
      ),
    );
  }
}