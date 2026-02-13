// File: lib/features/auth/presentation/pages/forgotpass_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/presentation/pages/new_pass_page.dart';

class ForgotPassPage extends StatelessWidget {
  const ForgotPassPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current theme color scheme
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface, // ✅ Adapted background (White or Dark Grey)
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER SECTION ---
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                // ✅ Icon matches text color (Black or White)
                icon: Icon(Icons.close, color: colorScheme.onSurface, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface, // ✅ Adapted text color
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 35),

          Text(
            "Enter your email for the authentication process",
            style: TextStyle(
              fontSize: 16,
              // ✅ Uses text color with opacity for subtitle effect
              color: colorScheme.onSurface.withOpacity(0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 25),

          // --- EMAIL INPUT ---
          TextField(
            style: TextStyle(color: colorScheme.onSurface), // ✅ Input text color
            decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6), // ✅ Hint color
                fontWeight: FontWeight.bold,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              // ✅ Borders adapt to theme (Black in Light, White in Dark)
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: colorScheme.onSurface),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: colorScheme.onSurface),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: colorScheme.onSurface, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // --- CONTINUE BUTTON ---
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const ResetPassPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                // ✅ Button uses Primary color (Light Blue or Deep Blue)
                backgroundColor: colorScheme.onSurface,
                // ✅ Text uses OnSurface (Black on Light Blue, White on Deep Blue)
                foregroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Continue",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}