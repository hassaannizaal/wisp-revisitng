import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LuxuryTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;

  const LuxuryTextField({
    super.key, required this.controller, required this.label, 
    required this.hintText, required this.prefixIcon, 
    this.isPassword = false, this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 2)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
            prefixIcon: Icon(prefixIcon, color: Colors.white54, size: 20),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.15), // Deep luxury input background
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
