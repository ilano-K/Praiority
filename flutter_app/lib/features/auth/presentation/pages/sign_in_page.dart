// File: lib/features/auth/presentation/pages/sign_in_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_app/core/utils/error_utils.dart';
import 'package:flutter_app/features/auth/presentation/manager/auth_controller.dart';
import 'package:flutter_app/features/auth/presentation/pages/forgot_pass_page.dart';
import 'package:flutter_app/features/auth/presentation/widgets/auth_components.dart';
import 'package:flutter_app/features/calendar/presentation/managers/calendar_provider.dart';
import 'package:flutter_app/features/settings/presentation/pages/work_hours.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class SignInPage extends ConsumerStatefulWidget {
  final VoidCallback onSwitch;
  const SignInPage({super.key, required this.onSwitch});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final TextEditingController _emailUnController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- LOGIC: STANDARD SIGN IN ---
  void _handleSignIn() async {
    final email = _emailUnController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    // Hide keyboard for better UX
    FocusScope.of(context).unfocus();
    final authController = ref.read(authControllerProvider.notifier);
    
    // Await the sign-in process
    await authController.signIn(email: email, password: password);

    final taskSyncService = ref.read(taskSyncServiceProvider);
    // sync tasks 
    unawaited(taskSyncService.syncAllTasks());
  }

  // --- LOGIC: GOOGLE SIGN IN ---
  void _handleGoogleSignIn() async {
    final authController = ref.read(authControllerProvider.notifier);
    await authController.signInWithGoogle();

    final taskSyncService = ref.read(taskSyncServiceProvider);
    // sync tasks 
    unawaited(taskSyncService.syncAllTasks());
  }

  // --- LOGIC: SHOW FORGOT PASSWORD POPUP ---
  void _showForgotPass(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const ForgotPassPage(),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailUnController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    // Error Listener
    ref.listen<AsyncValue>(
      authControllerProvider,
      (_, state) {
        if (!state.hasError) return;
        final appException = parseError(state.error!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appException.message)),
        );
      },
    );

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String logoPath = isDarkMode ? 'assets/images/DarkLogo.png' : 'assets/images/LightLogo.png';

    return Stack(
      children: [
        Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Image.asset(logoPath, height: 200),
                  const SizedBox(height: 20),
                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthField(hint: "Username/Email", controller: _emailUnController),
                  const SizedBox(height: 15),
                  AuthField(hint: "Password", isPass: true, controller: _passwordController),
                  const SizedBox(height: 25),
                  AuthComponents.buildButton(
                    context,
                    "Sign In",
                    onPressed: isLoading ? null : _handleSignIn,
                  ),
                  const SizedBox(height: 20),
                  AuthComponents.buildSocialDivider(context, "sign in"),
                  const SizedBox(height: 20),
                  AuthComponents.buildGoogleButton(context, onTap: _handleGoogleSignIn),
                  const SizedBox(height: 30),
                  
                  // Forgot Password Button
                  TextButton(
                    onPressed: () => _showForgotPass(context),
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Switch to Sign Up
                  GestureDetector(
                    onTap: widget.onSwitch,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                        children: [
                          const TextSpan(text: "Don't Have an Account? "),
                          TextSpan(
                            text: "Sign Up",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        
        // --- LOADING OVERLAY ---
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                color: colorScheme.primary, // Using your brand color
              ),
            ),
          ),
      ],
    );
  }
}