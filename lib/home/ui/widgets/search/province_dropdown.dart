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
    final options = ['Sin asignar', ...provinces];
    final selectedValue =
        value.isNotEmpty && provinces.contains(value) ? value : 'Sin asignar';

    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedValue,
      decoration: const InputDecoration(labelText: 'Provincia'),
      hint: const Text('Selecciona provincia'),
      items: options
          .map(
            (province) => DropdownMenuItem(
              value: province,
              child: Text(province, overflow: TextOverflow.ellipsis),
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
