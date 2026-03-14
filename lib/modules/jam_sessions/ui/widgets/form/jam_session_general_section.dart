import 'package:flutter/material.dart';

class JamSessionGeneralSection extends StatelessWidget {
  const JamSessionGeneralSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.requirementsController,
    required this.requiredValidator,
    required this.requirementsValidator,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController requirementsController;
  final String? Function(String?) requiredValidator;
  final String? Function(String?) requirementsValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Titulo de la jam'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: 'Descripcion'),
          maxLines: 3,
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: requirementsController,
          decoration: const InputDecoration(
            labelText: 'Instrumentos / perfiles requeridos',
            hintText: 'Ej. Voz, Guitarra, Bateria',
          ),
          maxLines: 2,
          validator: requirementsValidator,
        ),
      ],
    );
  }
}
