import 'package:flutter/material.dart';

class AnnouncementFormField extends StatelessWidget {
  const AnnouncementFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.minLines,
    this.maxLines,
    this.keyboardType,
    this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
    );
  }
}
