import 'package:flutter/material.dart';

class SmTextField extends StatelessWidget {
  const SmTextField({super.key, required this.label, this.onChanged, this.obscureText = false});

  final String label;
  final ValueChanged<String>? onChanged;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
      onChanged: onChanged,
    );
  }
}
