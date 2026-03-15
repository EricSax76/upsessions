import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.venueFormSectionBasics,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: localizations.venueFormFieldVenueName,
          ),
          validator: requiredValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: localizations.venueFormFieldDescription,
          ),
          maxLines: 3,
          validator: requiredValidator,
        ),
      ],
    );
  }
}
