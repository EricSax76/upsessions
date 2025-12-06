import 'package:flutter/material.dart';

class InstrumentDropdown extends StatelessWidget {
  const InstrumentDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const _options = ['Voz', 'Guitarra', 'Bajo', 'Batería', 'Teclado'];

  @override
  Widget build(BuildContext context) {
    final selectedValue = value.isNotEmpty && _options.contains(value)
        ? value
        : null;
    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      decoration: const InputDecoration(labelText: 'Instrumento'),
      hint: const Text('Selecciona instrumento'),
      isExpanded: true,
      items: _options
          .map(
            (instrument) =>
                DropdownMenuItem(value: instrument, child: Text(instrument)),
          )
          .toList(),
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
    );
  }
}
