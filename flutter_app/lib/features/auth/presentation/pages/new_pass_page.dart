import 'package:flutter/material.dart';

class ResetPassPage extends StatefulWidget {
  const ResetPassPage({super.key});

  @override
  State<ResetPassPage> createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // ✅ WRAP IN SCAFFOLD TO PROVIDE MATERIAL CONTEXT
    return Scaffold(
      backgroundColor: Colors
          .transparent, // Keeps the background of the previous screen visible if it's a sheet
      body: Container(
        // Ensure the container fills the screen if it's a full page,
        // or fits the content if it's a bottom sheet.
        height: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: SingleChildScrollView(
          // ✅ Add ScrollView to prevent overflow when keyboard appears
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20), // Top spacing for status bar
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
              ),
              const SizedBox(height: 30),

              // --- CONTINUE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    _handleNewPassword();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onSurface,
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
        ),
      ),
    );
  }

  void _handleNewPassword() async {}

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggle,
    required ColorScheme colorScheme,
  }) {
    // ✅ Material design widgets now have a Material ancestor (the Scaffold)
    return TextField(
      controller: controller,
      obscureText: isObscured,
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
