import 'package:flutter/material.dart';
import 'package:flutter_app/core/utils/error_utils.dart';
import 'package:flutter_app/features/auth/presentation/manager/auth_controller.dart';
import 'package:flutter_app/features/auth/presentation/widgets/auth_components.dart';
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


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

      if(!isValidEmail(email)){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid email address")),
        );
        return; 
      }

      // hide keyboard
      FocusScope.of(context).unfocus();
      final authController = ref.read(authControllerProvider.notifier);
      await authController.signIn(email: email, password: password);
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainCalendar()));
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
    //sign in logic
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
    final String logoPath = isDarkMode ? 'assets/images/DarkLogo.png' : 'assets/images/LightLogo.png';
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
              Text("Welcome Back!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
              const SizedBox(height: 30),
              AuthField(hint: "Username/Email", controller: _emailUnController),
              const SizedBox(height: 15),
              AuthField(hint: "Password", isPass: true, controller: _passwordController),
              const SizedBox(height: 25),
              AuthComponents.buildButton(context, "Sign In", onPressed: isLoading? null: _handleSignIn),
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