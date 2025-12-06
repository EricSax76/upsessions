import 'package:flutter/material.dart';

class ProvinceDropdown extends StatelessWidget {
  const ProvinceDropdown({
    super.key,
    required this.value,
    required this.provinces,
    required this.onChanged,
  });

  final String value;
  final List<String> provinces;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final hasProvinces = provinces.isNotEmpty;
    final dropdownItems = provinces.map((province) => DropdownMenuItem(value: province, child: Text(province))).toList();
    final selectedValue = hasProvinces && provinces.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      decoration: const InputDecoration(labelText: 'Provincia'),
      hint: const Text('Selecciona provincia'),
      isExpanded: true,
      items: dropdownItems,
      onChanged: hasProvinces
          ? (selected) {
              if (selected != null) {
                onChanged(selected);
              }
            }
          : null,
    );
  }
}
