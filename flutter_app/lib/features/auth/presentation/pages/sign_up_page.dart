import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/presentation/widgets/auth_components.dart';

class SignUpPage extends StatelessWidget {
  final VoidCallback onSwitch;
  const SignUpPage({super.key, required this.onSwitch});

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
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  // FIX 1: Centers content vertically
                  mainAxisAlignment: MainAxisAlignment.center, 
                  // FIX 2: Centers content horizontally
                  crossAxisAlignment: CrossAxisAlignment.center, 
                  children: [
                    const SizedBox(height: 20),
                    // Centering the logo
                    Center(child: Image.asset(logoPath, height: 220)),
                    const SizedBox(height: 20),
                    Text(
                      "Get Started!",
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.w900, 
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- PROPER WIDTH BOX ---
                    // FIX 3: Wrap the fixed-width box in a Center widget
                    Center(
                      child: SizedBox(
                        width: 320, 
                        child: Column(
                          children: [
                            // --- USE THE WIDGET DIRECTLY ---
                            const AuthField(hint: "Username"), 
                            const SizedBox(height: 15),
                            const AuthField(hint: "Email"),
                            const SizedBox(height: 15),
                            
                            // Set isPass to true for the eye icon toggle
                            const AuthField(hint: "Password", isPass: true), 
                            
                            const SizedBox(height: 25),

                            // --- USE THE STATIC CLASS FOR OTHERS ---
                            AuthComponents.buildButton(context, "Sign Up"),
                            const SizedBox(height: 20),
                            AuthComponents.buildSocialDivider(context, "sign up"),
                            const SizedBox(height: 20),
                            AuthComponents.buildGoogleButton(context),
                          ],
                        ),
                      ),
                    ),

                    // --- BOTTOM NAVIGATION LINKS ---
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32, top: 40),
                      child: GestureDetector(
                        onTap: onSwitch,
                        child: RichText(
                          textAlign: TextAlign.center, // Ensures text is centered
                          text: TextSpan(
                            style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                            children: [
                              const TextSpan(text: "Already Have an Account? "),
                              TextSpan(
                                text: "Sign In",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}