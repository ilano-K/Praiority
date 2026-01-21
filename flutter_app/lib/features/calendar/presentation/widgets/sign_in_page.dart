import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';

class SignInPage extends StatelessWidget {
  final VoidCallback onSwitch;
  const SignInPage({super.key, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final String logoPath = isDarkMode 
        ? 'assets/images/DarkLogo.png' 
        : 'assets/images/LightLogo.png';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                // Forces the Column to take up the full screen height
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes links to the bottom
                    children: [
                      // --- TOP CONTENT: LOGO & FORM ---
                      Column(
                        children: [
                          const SizedBox(height: 40),
                          Image.asset(logoPath, height: 220),
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
                          _buildField(context, "Username/Email"),
                          const SizedBox(height: 15),
                          _buildField(context, "Password", isPass: true),
                          const SizedBox(height: 25),
                          _buildButton(context, "Sign In"),
                          const SizedBox(height: 20),
                          _buildSocialDivider(context, "Sign in"),
                          const SizedBox(height: 20),
                          _buildGoogleButton(context),
                        ],
                      ),

                      // --- BOTTOM CONTENT: NAVIGATION LINKS ---
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32), // Precisely 8px from end
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () {}, 
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: colorScheme.onSurface, 
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: onSwitch,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildField(BuildContext context, String hint, {bool isPass = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      obscureText: isPass,
      style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface, width: 2),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainCalendar()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text, 
          style: TextStyle(color: colorScheme.surface, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildSocialDivider(BuildContext context, String mode) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1.2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text("or $mode with", style: const TextStyle(fontSize: 12)),
        ),
        const Expanded(child: Divider(thickness: 1.2)),
      ],
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainCalendar()),
        );
      },
      child: Container(
        width: 70, height: 45,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Image.asset('assets/images/G.png', height: 24)),
      ),
    );
  }
}