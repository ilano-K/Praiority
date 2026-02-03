// File: lib/features/calendar/presentation/widgets/app_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/core/providers/global_providers.dart';
import 'package:flutter_app/features/auth/data/auth_provider.dart';
import 'package:flutter_app/features/auth/presentation/manager/auth_controller.dart';
import 'package:flutter_app/features/auth/presentation/pages/auth_gate.dart';
// ❌ REMOVE THIS: You don't need to import SignInPage anymore
// import 'package:flutter_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/settings/presentation/managers/settings_provider.dart';
import 'package:flutter_app/features/settings/presentation/pages/work_hours.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart'; 
import '../../../../../core/theme/theme_notifier.dart';

class AppSidebar extends ConsumerStatefulWidget {
  final CalendarView currentView; 
  final Function(CalendarView) onViewSelected;

  const AppSidebar({
    super.key, 
    required this.currentView, 
    required this.onViewSelected
  });

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar> {
  bool _isExpanded = false;

  String _getViewLabel(CalendarView view) {
    switch (view) {
      case CalendarView.month: return "Month View";
      case CalendarView.week: return "Week View";
      case CalendarView.day: return "Day View";
      default: return "View";
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    label: _isExpanded ? "View" : _getViewLabel(widget.currentView),
                    isDark: isDark,
                  ),
                  _buildDrawerItem(
                  context, 
                  icon: Icons.access_time_outlined, 
                  label: "Working Hours",
                  onTap: () {
                    // 1. Close the drawer first to prevent UI overlap
                    Navigator.pop(context); 
                    
                    // 2. Navigate to WorkHours with the isFromSidebar flag set to true
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkHours(isFromSidebar: true),
                      ),
                    );
                  }, 
                ),
                  
                  // Google Sync Item
                  ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Image.asset(
                        'assets/images/G.png', 
                        width: 24, 
                        height: 24
                      ),
                    ),
                    title: Text(
                      "Google Sync", 
                      style: TextStyle(
                        fontSize: 17, 
                        fontWeight: FontWeight.w600, 
                        color: colorScheme.onSurface
                      )
                    ),
                    onTap: () => Navigator.pop(context),
                  ),

                  // ✅ FIXED LOG OUT LOGIC
            _buildDrawerItem(
                    context, 
                    icon: Icons.logout_outlined, 
                    label: "Log Out",
                    onTap: () async {
                      // 1. CAPTURE THE NAVIGATOR BEFORE AWAIT
                      // We save the navigator into a variable so we can use it 
                      // even if this widget dies/closes.
                      final navigator = Navigator.of(context);
                      final authController = ref.read(authControllerProvider.notifier);
                      final dbProvider = ref.read(localStorageServiceProvider);
                      final taskSyncService = ref.read(taskSyncServiceProvider);
                      final userPrefsSyncService = ref.read(userPrefSyncServiceProvider);

                      await taskSyncService.pushLocalChanges();
                      await userPrefsSyncService.pushLocalChanges();
                      await dbProvider.clearDatabase();
                      // 2. PERFORM SIGN OUT
                      await authController.signOut();

                      // 3. FORCE NAVIGATION USING THE CAPTURED VARIABLE
                      // We use 'navigator' instead of 'Navigator.of(context)'
                      // because 'context' might be dead now.
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const AuthGate(), 
                        ),
                        (route) => false, // Clears all history
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

  // ... (Keep your helper widgets: _buildDrawerItem, _buildExpandableItem, _buildSubItem, _buildThemeToggle exactly as they are) ...
  
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
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
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
  final isSelected = widget.currentView == view;

  return ListTile(
    tileColor: isSelected ? colorScheme.primary.withOpacity(0.08) : null,
    leading: Image.asset(
      isDark ? darkIcon : lightIcon, 
      width: 24, 
      height: 24,
      color: isSelected ? colorScheme.primary : null,
    ),
    title: Text(
      label, 
      style: TextStyle(
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, 
        color: isSelected ? colorScheme.primary : colorScheme.onSurface
      )
    ),
    onTap: () async {
      // 1. If it's already selected, just close the drawer immediately
      if (isSelected) {
        Navigator.pop(context);
        return;
      }

      // 2. Fetch data if moving to Month view
      if (view == CalendarView.month) {
        ref.read(calendarControllerProvider.notifier).getTasksByCondition();
      }

      // 3. TRIGGER THE VIEW CHANGE
      widget.onViewSelected(view); 

      // 4. THE MAGIC DELAY: 
      // We wait 250ms-300ms. This is the "sweet spot" where the calendar 
      // performs its heavy layout logic behind the drawer while the 
      // drawer is still opaque, hiding the "jumpy" update.
      await Future.delayed(const Duration(milliseconds: 300));

      // 5. Finally, slide the drawer away
      if (context.mounted) {
        Navigator.pop(context);
      }
    },
  );
}

Widget _buildThemeToggle(BuildContext context, WidgetRef ref, bool isDark) {
  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    width: 90, // Compact but accessible
    height: 44,
    decoration: BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: colorScheme.onSurface.withOpacity(0.1),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        _buildToggleSide(
          context,
          isActive: !isDark,
          icon: Icons.wb_sunny_rounded,
          onTap: () => isDark ? ref.read(themeProvider.notifier).toggleTheme() : null,
        ),
        _buildToggleSide(
          context,
          isActive: isDark,
          icon: Icons.nightlight_round,
          onTap: () => !isDark ? ref.read(themeProvider.notifier).toggleTheme() : null,
        ),
      ],
    ),
  );
}

Widget _buildToggleSide(BuildContext context, {required bool isActive, required IconData icon, required VoidCallback onTap}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          color: isActive 
              ? colorScheme.primary 
              : colorScheme.onSurface.withOpacity(0.3),
        ),
        child: Icon(
          icon,
          size: 24, // Standard "comfortable" size
          color: isActive 
              ? colorScheme.primary 
              : colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    ),
  );
}
}