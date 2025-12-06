import 'package:flutter/material.dart';

class ProfileTypeDropdown extends StatelessWidget {
  const ProfileTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const _types = ['Solista', 'Banda', 'Productor'];

  @override
  Widget build(BuildContext context) {
    final selectedValue =
        value.isNotEmpty && _types.contains(value) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      decoration: const InputDecoration(labelText: 'Tipo de perfil'),
      hint: const Text('Selecciona tipo'),
      isExpanded: true,
      items: _types
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
    );
  }
}
