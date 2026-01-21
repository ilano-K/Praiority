import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/pages/auth_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/theme/theme_notifier.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

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
                    child: Icon(
                      Icons.person, 
                      size: 70, 
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Juan Dela Cruz",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "juandelacruz@gmail.com",
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Divider(
                thickness: 1, 
                color: colorScheme.onSurface.withOpacity(0.1),
              ),
            ),

            // --- NAVIGATION LIST ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                children: [
                  // --- CUSTOM ASSET ICONS (VIEW DROPDOWN) ---
                  _buildExpandableItem(
                    context, 
                    lightIcon: 'assets/icons/view.png', 
                    darkIcon: 'assets/icons/viewDark.png', 
                    label: "View",
                    isDark: isDark,
                  ),
                  
                  // --- MATERIAL ICONS (PLACEHOLDERS) ---
                  _buildDrawerItem(
                    context, 
                    icon: Icons.access_time_outlined, // Working Hours
                    label: "Working Hours",
                  ),
                  _buildDrawerItem(
                    context, 
                    icon: Icons.cloud_sync_outlined, // Cloud Sync
                    label: "Cloud Sync",
                  ),
                  _buildDrawerItem(
                    context, 
                    icon: Icons.logout_outlined, // Log Out
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

  // --- UI HELPER: STANDARD DRAWER ITEM ---
  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon, 
    required String label, 
    VoidCallback? onTap
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurface, size: 28),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  // --- UI HELPER: EXPANDABLE ITEM (USING ASSETS) ---
  Widget _buildExpandableItem(BuildContext context, {
    required String lightIcon, 
    required String darkIcon, 
    required String label,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Image.asset(isDark ? darkIcon : lightIcon, width: 28, height: 28),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        iconColor: colorScheme.onSurface,
        collapsedIconColor: colorScheme.onSurface,
        childrenPadding: const EdgeInsets.only(left: 30),
        children: [
          _buildSubItem(context, "Month", 'assets/icons/month.png', 'assets/icons/monthDark.png', isDark),
          _buildSubItem(context, "Week", 'assets/icons/week.png', 'assets/icons/weekDark.png', isDark),
          _buildSubItem(context, "Day", 'assets/icons/day.png', 'assets/icons/dayDark.png', isDark),
        ],
      ),
    );
  }

  Widget _buildSubItem(BuildContext context, String label, String lightIcon, String darkIcon, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Image.asset(isDark ? darkIcon : lightIcon, width: 24, height: 24),
      title: Text(
        label, 
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        )
      ),
      onTap: () => Navigator.pop(context),
    );
  }

  // --- THEME TOGGLE (SAME AS PREVIOUS) ---
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