import 'package:flutter/material.dart';

class GenderRadioGroup extends StatelessWidget {
  const GenderRadioGroup({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _options = [
    'Sin asignar',
    'Cualquiera',
    'Femenino',
    'Masculino',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: [
        for (final option in _options)
          ChoiceChip(
            label: Text(option),
            selected: option == _options.first ? value.isEmpty : value == option,
            onSelected: (_) =>
                onChanged(option == _options.first ? '' : option),
          ),
      ],
    );
  }
}
