import 'package:flutter/material.dart';

class ProvincesListSection extends StatelessWidget {
  const ProvincesListSection({super.key, required this.provinces});

  final List<String> provinces;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: provinces.map((province) => Chip(label: Text(province))).toList(),
    );
  }
}
