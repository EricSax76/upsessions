import 'package:flutter/material.dart';

class StyleDropdown extends StatelessWidget {
  const StyleDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const _styles = [
    'Sin asignar',
    'Rock',
    'Pop',
    'Indie',
    'Funk',
    'Soul',
    'R&B',
    'Jazz',
    'Blues',
    'Hip-Hop',
    'Rap',
    'Reggaetón',
    'Trap',
    'Electrónica',
    'House',
    'Techno',
    'Reggae',
    'Ska',
    'Punk',
    'Metal',
    'Clásica',
    'Flamenco',
    'Folklore',
    'Latino',
    'Salsa',
    'Bachata',
    'Country',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedValue =
        value.isNotEmpty && _styles.contains(value) ? value : _styles.first;
    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      decoration: const InputDecoration(labelText: 'Estilo'),
      hint: const Text('Selecciona estilo'),
      isExpanded: true,
      items: _styles
          .map((style) => DropdownMenuItem(value: style, child: Text(style)))
          .toList(),
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected == _styles.first ? '' : selected);
        }
      },
    );
  }
}
