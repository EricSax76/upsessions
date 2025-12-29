import 'package:flutter/material.dart';

class InstrumentDropdown extends StatelessWidget {
  const InstrumentDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const _options = [
    'Sin asignar',
    'Voz',
    'Guitarra',
    'Bajo',
    'Batería',
    'Teclado',
    'Piano',
    'Saxofón',
    'Trompeta',
    'Violín',
    'Viola',
    'Violonchelo',
    'Contrabajo',
    'Flauta',
    'Clarinete',
    'Percusión',
    'DJ',
    'Producción',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedValue = value.isNotEmpty && _options.contains(value)
        ? value
        : _options.first;
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
          onChanged(selected == _options.first ? '' : selected);
        }
      },
    );
  }
}
