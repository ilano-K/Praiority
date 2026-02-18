// File: lib/features/auth/presentation/pages/forgotpass_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/auth/presentation/manager/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/errors/app_exceptions.dart'; // ✅ Import for error types

// 1. Convert to ConsumerStatefulWidget to access "ref"
class ForgotPassPage extends ConsumerStatefulWidget {
  const ForgotPassPage({super.key});

  @override
  ConsumerState<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends ConsumerState<ForgotPassPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter your email address."),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // 2. Trigger the Riverpod Controller
    ref.read(authControllerProvider.notifier).sendPasswordResetEmail(email);
  }

  @override
  Widget build(BuildContext context) {
    // 3. Watch Global Auth State (for loading spinner)
    final authState = ref.watch(authControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // 4. Listen for Side Effects (Success/Error)
    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      // HANDLE ERROR
      if (next.hasError && !next.isLoading) {
        // Extract the clean message from your AppException
        final message = next.error is AppException
            ? (next.error as AppException).message
            : next.error.toString();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // HANDLE SUCCESS
      // We check (prev?.isLoading == true) to ensure we only trigger when an action FINISHES
      if (!next.hasError && !next.isLoading && (prev?.isLoading ?? false)) {
        Navigator.pop(context); // Close sheet

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Reset link sent to ${_emailController.text}! Check your inbox.",
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER SECTION ---
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onSurface,
                    size: 28,
                  ),
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
                        color: colorScheme.onSurface,
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
                color: colorScheme.onSurface.withOpacity(0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 25),

            // --- EMAIL INPUT ---
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: colorScheme.onSurface),
              // Disable input while loading
              enabled: !authState.isLoading,
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
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
                  borderSide: BorderSide(
                    color: colorScheme.onSurface,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // --- CONTINUE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                // Disable button if loading
                onPressed: authState.isLoading ? null : _onContinuePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onSurface,
                  foregroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                // Show spinner or text based on Riverpod state
                child: authState.isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: colorScheme.surface,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
