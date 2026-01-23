import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/widgets/auth_components.dart';

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
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50), 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                          
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Column(
                              children: [
                                // --- USE THE NEW CLASS FOR FIELDS ---
                              const AuthField(hint: "Username/Email"), 
                              const SizedBox(height: 15),
                              
                              // Enabled the eye toggle by setting isPass to true
                              const AuthField(hint: "Password", isPass: true), 
                              
                              const SizedBox(height: 25),

                              // --- CONTINUE USING STATIC CLASS FOR OTHERS ---
                              AuthComponents.buildButton(context, "Sign In"),
                              const SizedBox(height: 20),
                              AuthComponents.buildSocialDivider(context, "sign in"),
                              const SizedBox(height: 20),
                              AuthComponents.buildGoogleButton(context),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 32), 
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
}