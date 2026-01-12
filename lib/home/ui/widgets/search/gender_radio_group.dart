import 'package:flutter/material.dart';

class GenderRadioGroup extends StatelessWidget {
  const GenderRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
  });

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
    final selectedValue =
        value.isNotEmpty && _options.contains(value) ? value : _options.first;
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedValue,
      decoration: const InputDecoration(labelText: 'Género'),
      hint: const Text('Selecciona género'),
      items: _options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(option, overflow: TextOverflow.ellipsis),
            ),
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
