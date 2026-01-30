import 'package:flutter/material.dart';

import 'announcement_form_field.dart';

class LocationInstrumentSection extends StatelessWidget {
  const LocationInstrumentSection({
    super.key,
    required this.cityController,
    required this.provinceController,
    required this.instrumentController,
    required this.stylesController,
  });

  final TextEditingController cityController;
  final TextEditingController provinceController;
  final TextEditingController instrumentController;
  final TextEditingController stylesController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación y Música',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AnnouncementFormField(
                controller: cityController,
                label: 'Ciudad',
                icon: Icons.location_city,
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : 'Campo obligatorio',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnnouncementFormField(
                controller: provinceController,
                label: 'Provincia',
                icon: Icons.map,
                validator: (value) => value != null && value.isNotEmpty
                    ? null
                    : 'Campo obligatorio',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnnouncementFormField(
          controller: instrumentController,
          label: 'Instrumento',
          icon: Icons.music_note,
          validator: (value) =>
              value != null && value.isNotEmpty ? null : 'Campo obligatorio',
        ),
        const SizedBox(height: 12),
        AnnouncementFormField(
          controller: stylesController,
          label: 'Estilos',
          hintText: 'Ej: Rock, Pop (separados por coma)',
          icon: Icons.queue_music,
        ),
      ],
    );
  }
}
