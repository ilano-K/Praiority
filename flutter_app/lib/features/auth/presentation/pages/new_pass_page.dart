import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/features/auth/presentation/manager/auth_controller.dart';
import 'package:flutter_app/core/errors/app_exceptions.dart';

// 1. Change to ConsumerStatefulWidget to use Riverpod 'ref'
class ResetPassPage extends ConsumerStatefulWidget {
  const ResetPassPage({super.key});

  @override
  ConsumerState<ResetPassPage> createState() => _ResetPassPageState();
}

class _ResetPassPageState extends ConsumerState<ResetPassPage> {
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isNewPassObscured = true;
  bool _isConfirmPassObscured = true;

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // 2. Logic to handle password update
  void _handleNewPassword() async {
    final newPass = _newPassController.text.trim();
    final confirmedPass = _confirmPassController.text.trim();

    final colorScheme = Theme.of(context).colorScheme;

    if (newPass.isEmpty || confirmedPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill in both fields"),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    if (newPass != confirmedPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Passwords do not match"),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    // Trigger update
    await ref.read(authControllerProvider.notifier).updatePassword(newPass);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 3. Watch the auth state to show loading spinner
    final authState = ref.watch(authControllerProvider);

    // 4. Listen for success/failure
    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        final message = next.error is AppException
            ? (next.error as AppException).message
            : next.error.toString();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: colorScheme.error),
        );
      }

      if (!next.hasError && !next.isLoading && (prev?.isLoading ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to login or home
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: double.infinity,
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
              const SizedBox(height: 20),
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
                        "Reset Password",
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
              const SizedBox(height: 30),
              Text(
                "Set the new password to your account, to sign in and access all the features",
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurface.withOpacity(0.6),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                "New Password",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              _buildPasswordField(
                controller: _newPassController,
                isObscured: _isNewPassObscured,
                onToggle: () =>
                    setState(() => _isNewPassObscured = !_isNewPassObscured),
                colorScheme: colorScheme,
                enabled: !authState.isLoading,
              ),
              const SizedBox(height: 20),
              Text(
                "Re-type New Password",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              _buildPasswordField(
                controller: _confirmPassController,
                isObscured: _isConfirmPassObscured,
                onToggle: () => setState(
                  () => _isConfirmPassObscured = !_isConfirmPassObscured,
                ),
                colorScheme: colorScheme,
                enabled: !authState.isLoading,
              ),
              const SizedBox(height: 30),

              // --- CONTINUE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleNewPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onSurface,
                    foregroundColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggle,
    required ColorScheme colorScheme,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      enabled: enabled,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isObscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: colorScheme.onSurface,
          ),
          onPressed: onToggle,
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
          borderSide: BorderSide(color: colorScheme.onSurface, width: 2),
        ),
      ),
    );
  }
}
