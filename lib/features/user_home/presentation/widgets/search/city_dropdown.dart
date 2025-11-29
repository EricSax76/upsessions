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
    final dropdownItems = cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList();
    final selectedValue = hasCities && cities.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      decoration: const InputDecoration(labelText: 'Ciudad'),
      hint: Text(hasCities ? 'Selecciona ciudad' : 'Sin ciudades disponibles'),
      isExpanded: true,
      items: dropdownItems,
      onChanged: hasCities
          ? (selected) {
              if (selected != null) {
                onChanged(selected);
              }
            }
          : null,
    );
  }
}
