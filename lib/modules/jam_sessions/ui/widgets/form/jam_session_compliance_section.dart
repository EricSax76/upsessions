import 'package:flutter/material.dart';

class JamSessionComplianceSection extends StatelessWidget {
  const JamSessionComplianceSection({
    super.key,
    required this.isPublic,
    required this.onIsPublicChanged,
    required this.maxAttendeesController,
    required this.entryFeeController,
    required this.ageRestrictionController,
    required this.optionalPositiveIntValidator,
    required this.optionalNonNegativeNumberValidator,
  });

  final bool isPublic;
  final ValueChanged<bool> onIsPublicChanged;
  final TextEditingController maxAttendeesController;
  final TextEditingController entryFeeController;
  final TextEditingController ageRestrictionController;
  final String? Function(String?) optionalPositiveIntValidator;
  final String? Function(String?) optionalNonNegativeNumberValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: isPublic,
          title: const Text('Jam session publica'),
          subtitle: Text(
            isPublic
                ? 'Visible para musicos en el listado publico.'
                : 'Solo visible por invitacion o canales internos.',
          ),
          onChanged: onIsPublicChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: maxAttendeesController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Aforo maximo (opcional)',
            hintText: 'Ej. 80',
          ),
          validator: optionalPositiveIntValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: entryFeeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Precio de entrada (opcional)',
            hintText: 'Ej. 12.50',
          ),
          validator: optionalNonNegativeNumberValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: ageRestrictionController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Edad minima (opcional)',
            hintText: 'Ej. 18',
          ),
          validator: optionalPositiveIntValidator,
        ),
      ],
    );
  }
}
