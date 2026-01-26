import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/presentation/widgets/auth_components.dart';
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';

class SignInPage extends StatefulWidget {
  final VoidCallback onSwitch;
  const SignInPage({super.key, required this.onSwitch});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailUnController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // --- LOGIC: STANDARD SIGN IN ---
    void _handleSignIn() {
      final identifier = _emailUnController.text.trim();

      // If the user included an '@', treat it as an email and validate
      if (identifier.contains('@')) {
        if (!isValidEmail(identifier)) {
          debugPrint("Invalid email format");
          return;
        }
      } else if (identifier.length < 3) {
        // If it's a username, ensure it's at least 3 characters
        debugPrint("Username too short");
        return;
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainCalendar()));
    }

  // --- LOGIC: GOOGLE SIGN IN ---
  void _handleGoogleSignIn() {
    debugPrint("Google Sign-In Triggered");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainCalendar()));
  }

  @override
  void dispose() {
    _emailUnController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String logoPath = isDarkMode ? 'assets/images/DarkLogo.png' : 'assets/images/LightLogo.png';

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
              Text("Welcome Back!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
              const SizedBox(height: 30),
              AuthField(hint: "Username/Email", controller: _emailUnController),
              const SizedBox(height: 15),
              AuthField(hint: "Password", isPass: true, controller: _passwordController),
              const SizedBox(height: 25),
              AuthComponents.buildButton(context, "Sign In", onPressed: _handleSignIn),
              const SizedBox(height: 20),
              AuthComponents.buildSocialDivider(context, "sign in"),
              const SizedBox(height: 20),
              AuthComponents.buildGoogleButton(context, onTap: _handleGoogleSignIn),
              
              const SizedBox(height: 30),

              // --- RESTORED FORGOT PASSWORD ---
              TextButton(
                onPressed: () {
                  debugPrint("Navigate to Forgot Password Page");
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: colorScheme.onSurface, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              GestureDetector(
                onTap: widget.onSwitch,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                    children: [
                      const TextSpan(text: "Don't Have an Account? "),
                      TextSpan(
                        text: "Sign Up", 
                        style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)
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
    );
  }
}