import 'package:flutter/material.dart';

class LocationSelector extends StatelessWidget {
  const LocationSelector({
    super.key,
    required this.province,
    required this.city,
    required this.provinces,
    required this.cities,
    required this.onProvinceChanged,
    required this.onCityChanged,
  });

  final String province;
  final String city;
  final List<String> provinces;
  final List<String> cities;
  final ValueChanged<String> onProvinceChanged;
  final ValueChanged<String> onCityChanged;

  @override
  Widget build(BuildContext context) {
    final hasProvinces = provinces.isNotEmpty;
    final hasCities = cities.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: hasProvinces && provinces.contains(province) ? province : null,
          decoration: const InputDecoration(labelText: 'Provincia'),
          hint: const Text('Selecciona provincia'),
          items: provinces.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: hasProvinces
              ? (selected) {
                  if (selected != null) {
                    onProvinceChanged(selected);
                  }
                }
              : null,
        ),
        if (!hasProvinces) ...[
          const SizedBox(height: 8),
          Text(
            'Carga provincias españolas desde Firestore (metadata/geography.provinces).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: hasCities && cities.contains(city) ? city : null,
          decoration: const InputDecoration(labelText: 'Ciudad'),
          hint: Text(hasProvinces ? 'Selecciona ciudad' : 'Sin ciudades disponibles'),
          items: cities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: hasCities
              ? (selected) {
                  if (selected != null) {
                    onCityChanged(selected);
                  }
                }
              : null,
        ),
        if (!hasCities) ...[
          const SizedBox(height: 8),
          Text(
            'Añade ciudades por provincia en Firestore (metadata/geography.citiesByProvince).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
