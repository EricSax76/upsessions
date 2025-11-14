import 'package:flutter/material.dart';

class StyleDropdown extends StatelessWidget {
  const StyleDropdown({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _styles = ['Soul', 'Rock', 'Pop', 'Funk', 'Indie'];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Estilo'),
      items: _styles.map((style) => DropdownMenuItem(value: style, child: Text(style))).toList(),
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
    );
  }
}
