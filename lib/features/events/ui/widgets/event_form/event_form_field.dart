import 'package:flutter/material.dart';

class EventFormField extends StatelessWidget {
  const EventFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.minLines,
    this.maxLines,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }
}
