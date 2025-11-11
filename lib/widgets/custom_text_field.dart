// =======================================================================
// lib/widgets/custom_text_field.dart
// (This is the UPDATED version)
// =======================================================================

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool isPassword;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly; // <-- ADDED
  final int? maxLines; // <-- ADDED
  final VoidCallback? onTap; // <-- ADDED

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.isPassword = false,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.readOnly = false, // <-- ADDED
    this.maxLines = 1, // <-- ADDED (default to 1)
    this.onTap, // <-- ADDED
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly, // <-- ADDED
      maxLines: maxLines, // <-- ADDED
      onTap: onTap, // <-- ADDED
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
    );
  }
}