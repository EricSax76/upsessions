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
    final dropdownItems = [
      const DropdownMenuItem(value: 'Sin asignar', child: Text('Sin asignar')),
      ...cities.map((city) => DropdownMenuItem(value: city, child: Text(city))),
    ];
    final selectedValue =
        value.isNotEmpty && cities.contains(value) ? value : 'Sin asignar';

    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      decoration: const InputDecoration(labelText: 'Ciudad'),
      hint: Text(hasCities ? 'Selecciona ciudad' : 'Sin ciudades disponibles'),
      isExpanded: true,
      items: dropdownItems,
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected == 'Sin asignar' ? '' : selected);
        }
      },
    );
  }
}
