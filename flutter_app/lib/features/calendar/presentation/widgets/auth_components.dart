import 'package:flutter/material.dart';
import 'package:flutter_app/features/calendar/presentation/pages/main_calendar.dart';

// --- CUSTOM TEXT FIELD WITH PASSWORD TOGGLE ---
class AuthField extends StatefulWidget {
  final String hint;
  final bool isPass;

  const AuthField({
    super.key,
    required this.hint,
    this.isPass = false,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPass; // Default to dots if it's a password field
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      obscureText: _obscureText,
      style: TextStyle(
        color: colorScheme.onSurface, 
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.5), 
          fontWeight: FontWeight.bold,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        
        // --- THE EYE ICON TOGGLE ---
        suffixIcon: widget.isPass
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
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

// --- SHARED AUTH UI COMPONENTS ---
class AuthComponents {
  // --- PRIMARY BUTTON ---
  static Widget buildButton(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity, 
      height: 55,
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

  // --- SOCIAL DIVIDER ---
  static Widget buildSocialDivider(BuildContext context, String mode) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 1.2, 
            color: colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "or $mode with", 
            style: TextStyle(
              fontSize: 12, 
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1.2, 
            color: colorScheme.onSurface.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  // --- GOOGLE BUTTON ---
  static Widget buildGoogleButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainCalendar()),
        );
      },
      child: Container(
        width: 70, 
        height: 45,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.onSurface, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Image.asset('assets/images/G.png', height: 24),
        ),
      ),
    );
  }
}