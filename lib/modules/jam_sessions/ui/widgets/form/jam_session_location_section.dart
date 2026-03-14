import 'package:flutter/material.dart';

class JamSessionLocationSection extends StatelessWidget {
  const JamSessionLocationSection({
    super.key,
    required this.locationController,
    required this.cityController,
    required this.provinceController,
    required this.readOnly,
    required this.requiredValidator,
  });

  final TextEditingController locationController;
  final TextEditingController cityController;
  final TextEditingController provinceController;
  final bool readOnly;
  final String? Function(String?) requiredValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: locationController,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: readOnly
                ? 'Nombre del local (autocompletado)'
                : 'Lugar exacto',
          ),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: cityController,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: readOnly ? 'Ciudad (autocompletado)' : 'Ciudad',
          ),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: provinceController,
          readOnly: readOnly,
          decoration: InputDecoration(
            labelText: readOnly
                ? 'Provincia (autocompletado)'
                : 'Provincia (opcional)',
          ),
        ),
      ],
    );
  }
}
