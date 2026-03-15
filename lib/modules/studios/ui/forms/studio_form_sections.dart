import 'package:flutter/material.dart';

import 'studio_form_draft.dart';

typedef StudioFieldValidator = String? Function(String?);

class StudioOpeningHoursSection extends StatelessWidget {
  const StudioOpeningHoursSection({
    super.key,
    required this.draft,
    this.border,
    this.fieldPadding = const EdgeInsets.only(bottom: 8),
    this.isDense = false,
  });

  final StudioFormDraft draft;
  final InputBorder? border;
  final EdgeInsets fieldPadding;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: draft.openingHoursControllers.entries
          .map(
            (entry) => Padding(
              padding: fieldPadding,
              child: TextFormField(
                controller: entry.value,
                decoration: InputDecoration(
                  labelText: entry.key.toUpperCase(),
                  hintText: '09:00-18:00',
                  border: border,
                  isDense: isDense,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class StudioRegulatorySection extends StatelessWidget {
  const StudioRegulatorySection({
    super.key,
    required this.draft,
    required this.requiredValidator,
    required this.positiveIntValidator,
    this.onNoiseChanged,
    this.border,
    this.openingHoursPadding = const EdgeInsets.only(bottom: 8),
    this.openingHoursDense = false,
  });

  final StudioFormDraft draft;
  final StudioFieldValidator requiredValidator;
  final StudioFieldValidator positiveIntValidator;
  final ValueChanged<bool>? onNoiseChanged;
  final InputBorder? border;
  final EdgeInsets openingHoursPadding;
  final bool openingHoursDense;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: draft.vatNumberController,
          decoration: InputDecoration(
            labelText: 'NIF-IVA (VAT Number)',
            helperText: 'LIVA - facturas intracomunitarias',
            border: border,
          ),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: draft.licenseNumberController,
          decoration: InputDecoration(
            labelText: 'Licencia municipal',
            helperText: 'Reglamento espectaculos - licencia de actividad',
            border: border,
          ),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: draft.maxRoomCapacityController,
          decoration: InputDecoration(
            labelText: 'Aforo maximo total',
            helperText: 'Reglamento espectaculos - seguridad',
            border: border,
          ),
          keyboardType: TextInputType.number,
          validator: positiveIntValidator,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Cumplimiento normativa acustica'),
          subtitle: const Text('Ordenanzas municipales de ruido'),
          value: draft.noiseOrdinanceCompliant,
          onChanged: onNoiseChanged,
        ),
        const SizedBox(height: 16),
        const Text(
          'Horario de apertura (LSSI Art. 10)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StudioOpeningHoursSection(
          draft: draft,
          border: border,
          fieldPadding: openingHoursPadding,
          isDense: openingHoursDense,
        ),
      ],
    );
  }
}

class StudioAccessibilitySection extends StatelessWidget {
  const StudioAccessibilitySection({
    super.key,
    required this.draft,
    required this.requiredValidator,
    this.onInsuranceExpiryTap,
    this.border,
    this.missingDateText = 'Seleccionar fecha (requerido)',
  });

  final StudioFormDraft draft;
  final StudioFieldValidator requiredValidator;
  final VoidCallback? onInsuranceExpiryTap;
  final InputBorder? border;
  final String missingDateText;

  @override
  Widget build(BuildContext context) {
    final insurance = draft.insuranceExpiry;
    final insuranceText = insurance == null
        ? missingDateText
        : '${insurance.day}/${insurance.month}/${insurance.year}';

    return Column(
      children: [
        TextFormField(
          controller: draft.accessibilityInfoController,
          decoration: InputDecoration(
            labelText: 'Informacion de accesibilidad',
            helperText: 'RD 1/2013 (LIONDAU) - accesibilidad',
            border: border,
          ),
          maxLines: 3,
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Caducidad seguro RC'),
          subtitle: Text(insuranceText),
          trailing: const Icon(Icons.calendar_today),
          onTap: onInsuranceExpiryTap,
        ),
      ],
    );
  }
}
