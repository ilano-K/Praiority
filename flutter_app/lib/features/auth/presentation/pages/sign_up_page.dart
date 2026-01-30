// File: lib/features/auth/presentation/pages/sign_up_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/core/utils/error_utils.dart';
import 'package:flutter_app/features/auth/presentation/manager/auth_controller.dart';
import 'package:flutter_app/features/auth/presentation/widgets/auth_components.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../calendar/presentation/pages/main_calendar.dart';

class SignUpPage extends ConsumerStatefulWidget {
  final VoidCallback onSwitch;
  const SignUpPage({super.key, required this.onSwitch});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- LOGIC: HANDLE SIGN UP ---
    void _handleSignUp() async {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password =_passwordController.text.trim();

      // 1. Basic empty check
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill out all the fields")),
        );
        return; 
      }

      // 2. Regex Check
      if (!isValidEmail(email)) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid email address")),
        );
        return; 
      }

      // --- ADDED SUCCESS NOTIFICATION ---
      // This triggers because the inputs are confirmed correct at this point
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Check your email for user verification"),
        ),
      );

      final authController = ref.read(authControllerProvider.notifier);
      await authController.signUp(username: username, email: email, password: password);
      // 3. Proceed if valid
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainCalendar()));
    }

  // --- LOGIC: HANDLE GOOGLE SIGN IN ---
  void _handleGoogleSignIn() {
  debugPrint("Initiating Google Sign-In flow...");
  // This is where you'll later add the 'google_sign_in' package logic
  Navigator.pushReplacement(
    context, 
    MaterialPageRoute(builder: (context) => const MainCalendar()),
  );
}

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // 2. Listen for Errors to show a SnackBar
    ref.listen<AsyncValue>(
      authControllerProvider,
      (_, state) {
        // Guard clause: If there is no error, do nothing.
        if (!state.hasError) return;

        // A. CONVERT: Pass the raw error to your utility
        // parseError() returns an 'AppException' object
        final appException = parseError(state.error!);

        // B. DISPLAY: Use .message to show the friendly text
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appException.message), // e.g. "Invalid email"
          ),
        );
      },
    );

    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final logoPath = isDarkMode ? 'assets/images/DarkLogo.png' : 'assets/images/LightLogo.png';

    final isLoading = authState.isLoading;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset(logoPath, height: 200),
              const SizedBox(height: 20),
              Text("Get Started!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
              const SizedBox(height: 30),
              AuthField(hint: "Username", controller: _usernameController),
              const SizedBox(height: 15),
              AuthField(hint: "Email", controller: _emailController),
              const SizedBox(height: 15),
              AuthField(hint: "Password", isPass: true, controller: _passwordController),
              const SizedBox(height: 25),
              AuthComponents.buildButton(context, "Sign Up", onPressed: isLoading? null : _handleSignUp),
              const SizedBox(height: 20),
              AuthComponents.buildSocialDivider(context, "sign up"),
              const SizedBox(height: 20),
              AuthComponents.buildGoogleButton(context, onTap: _handleGoogleSignIn),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: widget.onSwitch,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                    children: [
                      const TextSpan(text: "Already Have an Account? "),
                      TextSpan(text: "Sign In", style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}