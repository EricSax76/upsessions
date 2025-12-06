import 'package:flutter/material.dart';

class GenderRadioGroup extends StatelessWidget {
  const GenderRadioGroup({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _options = ['Cualquiera', 'Femenino', 'Masculino'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: [
        for (final option in _options)
          ChoiceChip(
            label: Text(option),
            selected: value == option,
            onSelected: (_) => onChanged(option),
          ),
      ],
    );
  }
}
