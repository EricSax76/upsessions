import 'package:flutter/material.dart';

class SmButton extends StatelessWidget {
  const SmButton({super.key, required this.label, this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.music_note),
      label: Text(label),
    );
  }
}
