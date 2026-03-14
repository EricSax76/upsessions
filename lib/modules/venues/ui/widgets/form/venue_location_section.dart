import 'package:flutter/material.dart';

class VenueLocationSection extends StatelessWidget {
  const VenueLocationSection({
    super.key,
    required this.addressController,
    required this.cityController,
    required this.provinceController,
    required this.postalCodeController,
    required this.requiredValidator,
  });

  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController provinceController;
  final TextEditingController postalCodeController;
  final FormFieldValidator<String> requiredValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: addressController,
          decoration: const InputDecoration(labelText: 'Dirección'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'Ciudad'),
                validator: requiredValidator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: provinceController,
                decoration: const InputDecoration(labelText: 'Provincia'),
                validator: requiredValidator,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: postalCodeController,
          decoration: const InputDecoration(
            labelText: 'Código postal (opcional)',
          ),
        ),
      ],
    );
  }
}
