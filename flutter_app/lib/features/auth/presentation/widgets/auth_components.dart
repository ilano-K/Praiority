// File: lib/features/auth/presentation/widgets/auth_components.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';

  // Standard Email Regex Pattern
  bool isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
    ).hasMatch(email);
  }

class AuthField extends StatefulWidget {
  final String hint;
  final bool isPass;
  final TextEditingController? controller;

  const AuthField({
    super.key,
    required this.hint,
    this.isPass = false,
    this.controller,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPass;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.5), 
          fontWeight: FontWeight.bold,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        suffixIcon: widget.isPass
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
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
}

class AuthComponents {
  static Widget buildButton(BuildContext context, String text, {VoidCallback? onPressed}) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity, 
      height: 55,
      child: ElevatedButton(
        // Calls the logic function passed from the page
        onPressed: onPressed, 
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

  static Widget buildSocialDivider(BuildContext context, String mode) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(thickness: 1.2, color: colorScheme.onSurface.withOpacity(0.2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "or $mode with", 
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
          ),
        ),
        Expanded(child: Divider(thickness: 1.2, color: colorScheme.onSurface.withOpacity(0.2))),
      ],
    );
  }

static Widget buildGoogleButton(BuildContext context, {VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      // FIX: Now using the passed 'onTap' function
      onTap: onTap ?? () => Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const MainCalendar()),
      ),
      child: Container(
        width: 70, 
        height: 45,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.onSurface, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Image.asset('assets/images/G.png', height: 24),
        ),
      ),
    );
  }

}