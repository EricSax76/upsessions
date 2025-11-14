import 'package:flutter/material.dart';

class ProfileTypeDropdown extends StatelessWidget {
  const ProfileTypeDropdown({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _types = ['Solista', 'Banda', 'Productor'];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Tipo de perfil'),
      items: _types.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
    );
  }
}
