import 'package:flutter/material.dart';

class CreateGroupTextField extends StatelessWidget {
  const CreateGroupTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.keyboardType,
    this.maxLines,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText, hintText: hintText),
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      minLines: 1,
      autofocus: autofocus,
    );
  }
}
