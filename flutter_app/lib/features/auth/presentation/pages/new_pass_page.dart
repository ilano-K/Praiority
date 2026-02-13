import 'package:flutter/material.dart';

class ResetPassPage extends StatefulWidget {
  const ResetPassPage({super.key});

  @override
  State<ResetPassPage> createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
  // Controllers to capture the new passwords
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // State to toggle password visibility
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
    // Access the current theme color scheme
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      // Matching the rounded corner style from your mockup
      decoration: BoxDecoration(
        color: colorScheme.surface, // ✅ Adapted background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Hugs content like the design
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER SECTION ---
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                // ✅ Icon matches text color
                icon: Icon(Icons.close, color: colorScheme.onSurface, size: 28),
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
                      color: colorScheme.onSurface, // ✅ Adapted text color
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32), // Balance for centering
            ],
          ),
          const SizedBox(height: 30),

          // --- DESCRIPTION TEXT ---
          Text(
            "Set the new password to your account, to sign in and access all the features",
            style: TextStyle(
              fontSize: 15,
              // ✅ Uses text color with opacity
              color: colorScheme.onSurface.withOpacity(0.6),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 25),

          // --- NEW PASSWORD SECTION ---
          Text(
            "New Password",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface, // ✅ Adapted text color
            ),
          ),
          const SizedBox(height: 10),
          _buildPasswordField(
            controller: _newPassController,
            isObscured: _isNewPassObscured,
            onToggle: () => setState(() => _isNewPassObscured = !_isNewPassObscured),
            colorScheme: colorScheme, // ✅ Pass scheme
          ),
          const SizedBox(height: 20),

          // --- RE-TYPE PASSWORD SECTION ---
          Text(
            "Re-type New Password",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface, // ✅ Adapted text color
            ),
          ),
          const SizedBox(height: 10),
          _buildPasswordField(
            controller: _confirmPassController,
            isObscured: _isConfirmPassObscured,
            onToggle: () => setState(() => _isConfirmPassObscured = !_isConfirmPassObscured),
            colorScheme: colorScheme, // ✅ Pass scheme
          ),
          const SizedBox(height: 30),

          // --- CONTINUE BUTTON ---
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Logic to update password in your AuthController
              },
              style: ElevatedButton.styleFrom(
                // ✅ Button uses Primary color
                backgroundColor: colorScheme.onSurface,
                // ✅ Text uses OnSurface
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

  // Reusable widget for the password fields to keep code clean
  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggle,
    required ColorScheme colorScheme, // ✅ Receive scheme
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      // ✅ Input text matches theme
      style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: 'Password',
        // ✅ Hint text uses opacity
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        suffixIcon: IconButton(
          icon: Icon(
            isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: colorScheme.onSurface, // ✅ Icon color matches theme
          ),
          onPressed: onToggle,
        ),
        // ✅ Borders adapt to theme
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