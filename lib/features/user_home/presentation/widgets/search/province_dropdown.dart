import 'package:flutter/material.dart';

class ProvinceDropdown extends StatelessWidget {
  const ProvinceDropdown({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _provinces = ['CDMX', 'Jalisco', 'Monterrey', 'Yucatán'];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Estado'),
      isExpanded: true,
      items: _provinces.map((province) => DropdownMenuItem(value: province, child: Text(province))).toList(),
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected);
        }
      },
    );
  }
}
