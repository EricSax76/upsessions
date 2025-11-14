import 'package:flutter/material.dart';

class ProvincesListSection extends StatelessWidget {
  const ProvincesListSection({super.key});

  static const _provinces = ['CDMX', 'Jalisco', 'Puebla', 'Nuevo León', 'Quintana Roo'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: _provinces.map((province) => Chip(label: Text(province))).toList(),
    );
  }
}
