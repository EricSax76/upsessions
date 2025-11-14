import 'package:flutter/material.dart';

class LocationSelector extends StatelessWidget {
  const LocationSelector({
    super.key,
    required this.province,
    required this.city,
    required this.onProvinceChanged,
    required this.onCityChanged,
  });

  final String province;
  final String city;
  final ValueChanged<String> onProvinceChanged;
  final ValueChanged<String> onCityChanged;

  static const _provinces = ['CDMX', 'Jalisco', 'Monterrey', 'Yucatán'];
  static const _cities = ['Ciudad de México', 'Guadalajara', 'Monterrey', 'Cancún'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: province,
          decoration: const InputDecoration(labelText: 'Estado'),
          items: _provinces.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (selected) {
            if (selected != null) {
              onProvinceChanged(selected);
            }
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: city,
          decoration: const InputDecoration(labelText: 'Ciudad'),
          items: _cities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (selected) {
            if (selected != null) {
              onCityChanged(selected);
            }
          },
        ),
      ],
    );
  }
}
