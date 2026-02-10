// File: lib/features/auth/presentation/pages/forgotpass_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/presentation/pages/new_pass_page.dart';

class ForgotPassPage extends StatelessWidget {
  const ForgotPassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                icon: const Icon(Icons.close, color: Colors.black, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 35),

          const Text(
            "Enter your email for the authentication process",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 25),

          TextField(
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: 'Email',
              hintStyle: const TextStyle(
                color: Colors.black54, 
                fontWeight: FontWeight.bold
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.black, width: 2),
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
                // 1. Close the current Forgot Password sheet
                Navigator.pop(context);

                // 2. Open the Reset Password sheet
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
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
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