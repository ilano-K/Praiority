// File: lib/features/calendar/presentation/widgets/app_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/core/errors/app_exceptions.dart';
import 'package:flutter_app/core/providers/global_providers.dart';
import 'package:flutter_app/features/auth/presentation/manager/auth_controller.dart';
import 'package:flutter_app/features/auth/presentation/pages/auth_gate.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_controller.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/dialogs/app_confirmation_dialog.dart';
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
    required this.onViewSelected,
  });

  @override
  ConsumerState<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends ConsumerState<AppSidebar> {
  bool _isExpanded = false;
  bool _isLoggingOut = false;
  bool _isSyncingGoogle = false; // New state for Google Sync

  String _getViewLabel(CalendarView view) {
    switch (view) {
      case CalendarView.month:
        return "Month View";
      case CalendarView.week:
        return "Week View";
      case CalendarView.day:
        return "Day View";
      default:
        return "View";
    }
  }

  /// ✅ NEW: Handle Google Calendar Sync
  Future<void> _handleGoogleSync() async {
    if (_isSyncingGoogle) return;

    setState(() => _isSyncingGoogle = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final googleSyncNotfier = ref.read(googleSyncNotifierProvider.notifier);
      await googleSyncNotfier.performSync();

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text("Google Calendar synced successfully!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("[Google Sync Error]: $e");
      if (mounted) {
        final appError = parseError(e);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(appError.title),
            content: Text(appError.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncingGoogle = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final authController = ref.read(authControllerProvider.notifier);
      final dbProvider = ref.read(localStorageServiceProvider);
      final taskSyncService = ref.read(taskSyncServiceProvider);
      final userPrefsSyncService = ref.read(userPrefSyncServiceProvider);

      await taskSyncService.pushLocalChanges();
      await userPrefsSyncService.pushLocalChanges();
      await dbProvider.clearDatabase();
      await authController.signOut();

      if (!mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const AuthGate(showLogoutMessage: true),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint("[Logout Error]: $e");
      if (mounted) {
        setState(() => _isLoggingOut = false);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text(
              "Logout sync failed. Please check your connection.",
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
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
        child: Stack(
          children: [
            Column(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    children: [
                      _buildExpandableItem(
                        context,
                        lightIcon: 'assets/icons/view.png',
                        darkIcon: 'assets/icons/viewDark.png',
                        label: _isExpanded
                            ? "View"
                            : _getViewLabel(widget.currentView),
                        isDark: isDark,
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.access_time_outlined,
                        label: "Working Hours",
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WorkHours(isFromSidebar: true),
                            ),
                          );
                        },
                      ),

                      // ✅ UPDATED: Google Sync Item with Loading State
                      ListTile(
                        leading: _isSyncingGoogle
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: Image.asset(
                                  'assets/images/G.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                        title: Text(
                          _isSyncingGoogle ? "Syncing..." : "Google Sync",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        onTap: _isSyncingGoogle ? null : _handleGoogleSync,
                      ),

                      _buildDrawerItem(
                        context,
                        icon: Icons.logout_outlined,
                        label: "Log Out",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AppConfirmationDialog(
                              title: "Log Out",
                              message: "Are you sure you want to log out?",
                              confirmLabel: "Log Out",
                              isDestructive: true,
                              onConfirm: _handleLogout,
                            ),
                          );
                        },
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

            // Global Logout Loading Overlay
            if (_isLoggingOut)
              Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
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
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  Widget _buildExpandableItem(
    BuildContext context, {
    required String lightIcon,
    required String darkIcon,
    required String label,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        onExpansionChanged: (expanded) =>
            setState(() => _isExpanded = expanded),
        leading: Image.asset(
          isDark ? darkIcon : lightIcon,
          width: 28,
          height: 28,
        ),
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
          _buildSubItem(
            context,
            "Month",
            'assets/images/month.png',
            'assets/images/monthDark.png',
            isDark,
            CalendarView.month,
          ),
          _buildSubItem(
            context,
            "Week",
            'assets/images/week.png',
            'assets/images/weekDark.png',
            isDark,
            CalendarView.week,
          ),
          _buildSubItem(
            context,
            "Day",
            'assets/images/day.png',
            'assets/images/dayDark.png',
            isDark,
            CalendarView.day,
          ),
        ],
      ),
    );
  }

  Widget _buildSubItem(
    BuildContext context,
    String label,
    String lightIcon,
    String darkIcon,
    bool isDark,
    CalendarView view,
  ) {
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
          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      onTap: () async {
        if (isSelected) {
          Navigator.pop(context);
          return;
        }
        widget.onViewSelected(view);
        await Future.delayed(const Duration(milliseconds: 300));
        if (context.mounted) Navigator.pop(context);
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 90,
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
            onTap: () =>
                isDark ? ref.read(themeProvider.notifier).toggleTheme() : null,
          ),
          _buildToggleSide(
            context,
            isActive: isDark,
            icon: Icons.nightlight_round,
            onTap: () =>
                !isDark ? ref.read(themeProvider.notifier).toggleTheme() : null,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSide(
    BuildContext context, {
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Icon(
          icon,
          size: 24,
          color: isActive
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.3),
        ),
      ),
    );
  }
}
