import 'package:flutter/material.dart';

class PremiumOnboardingTextField extends StatelessWidget {
  const PremiumOnboardingTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.minLines,
    this.maxLines,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final int? minLines;
  final int? maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: textInputAction,
      decoration: InputDecoration(labelText: hintText),
    );
  }
}
