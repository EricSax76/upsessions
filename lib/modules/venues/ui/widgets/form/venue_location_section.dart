import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.venueFormSectionLocation,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: addressController,
          decoration: InputDecoration(
            labelText: localizations.venueFormFieldAddress,
          ),
          validator: requiredValidator,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: localizations.venueFieldCity,
                ),
                validator: requiredValidator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: provinceController,
                decoration: InputDecoration(
                  labelText: localizations.venueFieldProvince,
                ),
                validator: requiredValidator,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: postalCodeController,
          decoration: InputDecoration(
            labelText: localizations.venueFormFieldPostalCodeOptional,
          ),
        ),
      ],
    );
  }
}
