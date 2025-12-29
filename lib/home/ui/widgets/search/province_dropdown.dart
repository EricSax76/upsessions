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
    final dropdownItems = [
      const DropdownMenuItem(value: 'Sin asignar', child: Text('Sin asignar')),
      ...provinces.map(
        (province) => DropdownMenuItem(value: province, child: Text(province)),
      ),
    ];
    final selectedValue =
        value.isNotEmpty && provinces.contains(value) ? value : 'Sin asignar';

    return DropdownButtonFormField<String>(
      initialValue: selectedValue,
      decoration: const InputDecoration(labelText: 'Provincia'),
      hint: const Text('Selecciona provincia'),
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
