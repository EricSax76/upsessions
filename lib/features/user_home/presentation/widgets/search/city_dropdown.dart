import 'package:flutter/material.dart';

class CityDropdown extends StatelessWidget {
  const CityDropdown({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _cities = ['Ciudad de México', 'Guadalajara', 'Monterrey', 'Cancún'];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Ciudad'),
      items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
    );
  }
}
