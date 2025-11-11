// =======================================================================
// widgets/primary_button.dart
// Reusable primary button for forms.
// =======================================================================

import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Widget? child;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    this.text = '',
    this.child,
  }) : assert(text != '' || child != null);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child ?? Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}