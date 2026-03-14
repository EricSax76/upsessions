import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contacto y licencia',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: contactEmailController,
          decoration: const InputDecoration(labelText: 'Email de contacto'),
          validator: emailValidator,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: contactPhoneController,
          decoration: const InputDecoration(labelText: 'Teléfono de contacto'),
          validator: requiredValidator,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: licenseNumberController,
          decoration: const InputDecoration(labelText: 'Nº de licencia'),
          validator: requiredValidator,
        ),
      ],
    );
  }
}
