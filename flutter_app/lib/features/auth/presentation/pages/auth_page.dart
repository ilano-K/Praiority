import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/sign_in_page.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/sign_up_page.dart';
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Toggle between Sign In and Sign Up
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
        // Switch between pages with a smooth animation
        child: _isLogin 
            ? SignInPage(onSwitch: _toggleAuth, key: const ValueKey('SignIn')) 
            : SignUpPage(onSwitch: _toggleAuth, key: const ValueKey('SignUp')),
      ),
    );
  }
}