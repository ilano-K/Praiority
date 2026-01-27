import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/data/auth_provider.dart';
import 'package:flutter_app/features/auth/presentation/pages/auth_page.dart';
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        if (state.session != null) return const MainCalendar(); // Auto-show App
        return const AuthPage(); // Auto-show Login
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const AuthPage(),
    );
  }
}