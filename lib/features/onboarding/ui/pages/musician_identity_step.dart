import 'package:flutter/material.dart';
import 'package:upsessions/core/utils/age_gate_utils.dart';
import '../widgets/musician_onboarding_step_card.dart';
import '../widgets/premium_onboarding_textfield.dart';

class MusicianIdentityStep extends StatelessWidget {
  const MusicianIdentityStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.instrumentController,
    required this.birthDate,
    required this.birthDateLabel,
    required this.onBirthDateChanged,
    required this.legalGuardianEmailController,
    required this.legalGuardianConsent,
    required this.onLegalGuardianConsentChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController instrumentController;
  final DateTime? birthDate;
  final String birthDateLabel;
  final ValueChanged<DateTime?> onBirthDateChanged;
  final TextEditingController legalGuardianEmailController;
  final bool legalGuardianConsent;
  final ValueChanged<bool> onLegalGuardianConsentChanged;

  bool get _isMinor => isMusicianMinor(birthDate);

  Future<DateTime?> _selectBirthDate(BuildContext context) async {
    final today = DateTime.now();
    final initialDate =
        birthDate ??
        DateTime(today.year - kLegalAdultAge, today.month, today.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(today.year - 100, 1, 1),
      lastDate: DateTime(today.year, today.month, today.day),
      helpText: 'Fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );
    if (pickedDate != null) {
      onBirthDateChanged(pickedDate);
    }
    return pickedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: MusicianOnboardingStepCard(
        title: 'Tu identidad musical',
        description:
            'Comparte tu nombre artístico y el/los instrumento/s que tocas.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PremiumOnboardingTextField(
              controller: nameController,
              hintText: 'Nombre artístico',
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            PremiumOnboardingTextField(
              controller: instrumentController,
              hintText: 'Instrumento principal',
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FormField<DateTime>(
              initialValue: birthDate,
              validator: (_) {
                if (birthDate == null) {
                  return 'Selecciona tu fecha de nacimiento';
                }
                final age = calculateAgeYears(birthDate);
                if (age == null) {
                  return 'La fecha de nacimiento no es válida';
                }
                if (age < kMinimumMusicianAge) {
                  return 'Debes tener al menos 14 años';
                }
                return null;
              },
              builder: (field) {
                final hasDate = birthDate != null && birthDateLabel.isNotEmpty;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final pickedDate = await _selectBirthDate(context);
                        field.didChange(pickedDate ?? birthDate);
                      },
                      icon: const Icon(Icons.cake_outlined),
                      label: Text(
                        hasDate
                            ? 'Fecha de nacimiento: $birthDateLabel'
                            : 'Seleccionar fecha de nacimiento',
                      ),
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (_isMinor) ...[
              const SizedBox(height: 16),
              PremiumOnboardingTextField(
                controller: legalGuardianEmailController,
                hintText: 'Email del tutor legal',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final email = (value ?? '').trim();
                  if (email.isEmpty) {
                    return 'Requerido para menores de edad';
                  }
                  if (!isValidEmailAddress(email)) {
                    return 'Email no válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              FormField<bool>(
                initialValue: legalGuardianConsent,
                validator: (value) {
                  if (value == true) return null;
                  return 'Debes confirmar el consentimiento del tutor legal';
                },
                builder: (field) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: legalGuardianConsent,
                        title: const Text(
                          'Confirmo que mi tutor legal autoriza el uso de la app',
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (value) {
                          final checked = value ?? false;
                          onLegalGuardianConsentChanged(checked);
                          field.didChange(checked);
                        },
                      ),
                      if (field.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            field.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
