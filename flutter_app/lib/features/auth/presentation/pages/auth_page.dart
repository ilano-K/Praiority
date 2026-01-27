import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/data/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter_app/features/auth/presentation/pages/sign_up_page.dart'; 

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool _isLogin = true;

  void _toggleAuth() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _isLogin
            ? SignInPage(
                key: const ValueKey('SignIn'), // Key ensures animation works
                onSwitch: _toggleAuth,
              )
            : SignUpPage(
                key: const ValueKey('SignUp'),
                onSwitch: _toggleAuth,
              ),
      ),
    );
  }
}