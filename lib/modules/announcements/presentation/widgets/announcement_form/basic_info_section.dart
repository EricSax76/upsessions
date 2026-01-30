import 'package:flutter/material.dart';

import 'announcement_form_field.dart';

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({
    super.key,
    required this.titleController,
    required this.bodyController,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Básica',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        AnnouncementFormField(
          controller: titleController,
          label: 'Título',
          icon: Icons.title,
          validator: (value) =>
              value != null && value.isNotEmpty ? null : 'Campo obligatorio',
        ),
        const SizedBox(height: 12),
        AnnouncementFormField(
          controller: bodyController,
          label: 'Descripción',
          icon: Icons.description,
          maxLines: 4,
          validator: (value) => value != null && value.length >= 10
              ? null
              : 'Describe mejor tu anuncio',
        ),
      ],
    );
  }
}
