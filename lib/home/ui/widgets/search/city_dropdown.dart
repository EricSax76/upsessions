import 'package:flutter/material.dart';

class CityDropdown extends StatelessWidget {
  const CityDropdown({
    super.key,
    required this.value,
    required this.cities,
    required this.onChanged,
  });

  final String value;
  final List<String> cities;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasCities = cities.isNotEmpty;
    final options = ['Sin asignar', ...cities];
    final selectedValue =
        value.isNotEmpty && cities.contains(value) ? value : 'Sin asignar';

    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedValue,
      decoration: const InputDecoration(labelText: 'Ciudad'),
      hint: Text(hasCities ? 'Selecciona ciudad' : 'Sin ciudades disponibles'),
      items: options
          .map(
            (city) => DropdownMenuItem(
              value: city,
              child: Text(city, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected == 'Sin asignar' ? '' : selected);
        }
      },
    );
  }
}
