// File: lib/features/auth/presentation/pages/sign_up_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/presentation/widgets/auth_components.dart';
import '../../../calendar/presentation/pages/main_calendar.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback onSwitch;
  const SignUpPage({super.key, required this.onSwitch});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- LOGIC: HANDLE SIGN UP ---
    void _handleSignUp() {
      final email = _emailController.text.trim();
      
      // 1. Basic empty check
      if (email.isEmpty) {
        debugPrint("Please enter an email");
        return;
      }

      // 2. Regex Check
      if (!isValidEmail(email)) {
        // This is where you'd show your AppWarningDialog
        debugPrint("Please enter a valid email address (e.g. name@example.com)");
        return;
      }

      // 3. Proceed if valid
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainCalendar()));
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final logoPath = isDarkMode ? 'assets/images/DarkLogo.png' : 'assets/images/LightLogo.png';

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
              AuthComponents.buildButton(context, "Sign Up", onPressed: _handleSignUp),
              const SizedBox(height: 20),
              AuthComponents.buildSocialDivider(context, "sign up"),
              const SizedBox(height: 20),
              AuthComponents.buildGoogleButton(context, onTap: _handleSignUp),
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