import 'package:flutter/material.dart';

class VenueBasicsSection extends StatelessWidget {
  const VenueBasicsSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.requiredValidator,
  });

  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final FormFieldValidator<String> requiredValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información del local',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nombre del local'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: 'Descripción'),
          maxLines: 3,
          validator: requiredValidator,
        ),
      ],
    );
  }
}
