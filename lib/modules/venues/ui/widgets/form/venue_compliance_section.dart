import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class VenueComplianceSection extends StatelessWidget {
  const VenueComplianceSection({
    super.key,
    required this.maxCapacityController,
    required this.accessibilityInfoController,
    required this.isPublic,
    required this.onIsPublicChanged,
    required this.requiredValidator,
    required this.positiveIntValidator,
  });

  final TextEditingController maxCapacityController;
  final TextEditingController accessibilityInfoController;
  final bool isPublic;
  final ValueChanged<bool> onIsPublicChanged;
  final FormFieldValidator<String> requiredValidator;
  final FormFieldValidator<String> positiveIntValidator;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.venueFormSectionCompliance,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: maxCapacityController,
          decoration: InputDecoration(
            labelText: localizations.venueFormFieldMaxCapacity,
          ),
          validator: positiveIntValidator,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: accessibilityInfoController,
          decoration: InputDecoration(
            labelText: localizations.venueFormFieldAccessibility,
          ),
          validator: requiredValidator,
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          value: isPublic,
          contentPadding: EdgeInsets.zero,
          onChanged: onIsPublicChanged,
          title: Text(localizations.venueFormVisibleToMusicians),
          subtitle: Text(localizations.venueFormVisibleToMusiciansHint),
        ),
      ],
    );
  }
}
