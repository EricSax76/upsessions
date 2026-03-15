import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class VenueContactSection extends StatelessWidget {
  const VenueContactSection({
    super.key,
    required this.contactEmailController,
    required this.contactPhoneController,
    required this.licenseNumberController,
    required this.requiredValidator,
    required this.emailValidator,
  });

  final TextEditingController contactEmailController;
  final TextEditingController contactPhoneController;
  final TextEditingController licenseNumberController;
  final FormFieldValidator<String> requiredValidator;
  final FormFieldValidator<String> emailValidator;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.venueFormSectionContact,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: contactEmailController,
          decoration: InputDecoration(
            labelText: localizations.venueFormFieldContactEmail,
          ),
          validator: emailValidator,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: contactPhoneController,
          decoration: InputDecoration(
            labelText: localizations.venueFormFieldContactPhone,
          ),
          validator: requiredValidator,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: licenseNumberController,
          decoration: InputDecoration(
            labelText: localizations.venueFormFieldLicenseNumber,
          ),
          validator: requiredValidator,
        ),
      ],
    );
  }
}
