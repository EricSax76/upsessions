import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:upsessions/core/utils/age_gate_utils.dart';
import 'package:upsessions/modules/profile/cubit/profile_form_cubit.dart';

class ProfileBasicInfoFields extends StatelessWidget {
  const ProfileBasicInfoFields({super.key});

  Future<void> _pickBirthDate(
    BuildContext context, {
    required DateTime? currentValue,
    required ValueChanged<DateTime?> onChanged,
  }) async {
    final today = DateTime.now();
    final initialDate =
        currentValue ??
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
      onChanged(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We access the cubit directly as it should be provided by the parent ProfileForm
    final cubit = context.read<ProfileFormCubit>();

    return BlocBuilder<ProfileFormCubit, ProfileFormState>(
      buildWhen: (previous, current) =>
          previous.bio != current.bio ||
          previous.location != current.location ||
          previous.availableForHire != current.availableForHire ||
          previous.birthDate != current.birthDate ||
          previous.legalGuardianEmail != current.legalGuardianEmail ||
          previous.legalGuardianConsent != current.legalGuardianConsent,
      builder: (context, state) {
        final birthDate = state.birthDate;
        final birthDateLabel = birthDate == null
            ? 'Seleccionar fecha de nacimiento'
            : 'Fecha de nacimiento: ${DateFormat('dd/MM/yyyy').format(birthDate)}';
        final isMinor = isMusicianMinor(birthDate);

        return Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => _pickBirthDate(
                  context,
                  currentValue: birthDate,
                  onChanged: cubit.birthDateChanged,
                ),
                icon: const Icon(Icons.cake_outlined),
                label: Text(birthDateLabel),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.bio,
              decoration: const InputDecoration(labelText: 'Biografía'),
              maxLines: 4,
              onChanged: cubit.bioChanged,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.location,
              decoration: const InputDecoration(labelText: 'Ubicación'),
              onChanged: cubit.locationChanged,
            ),
            const SizedBox(height: 12),
            if (isMinor) ...[
              TextFormField(
                initialValue: state.legalGuardianEmail,
                decoration: const InputDecoration(
                  labelText: 'Email del tutor legal',
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: cubit.legalGuardianEmailChanged,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: state.legalGuardianConsent,
                title: const Text('Confirmo consentimiento del tutor legal'),
                subtitle: const Text(
                  'Requerido para perfiles de menores de edad.',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) =>
                    cubit.legalGuardianConsentChanged(value ?? false),
              ),
              const SizedBox(height: 12),
            ],
            SwitchListTile(
              title: const Text('Disponible para contratación'),
              subtitle: const Text(
                'Márcalo si quieres que los organizadores puedan buscar tu perfil y contactarte para eventos.',
              ),
              value: state.availableForHire,
              onChanged: cubit.availableForHireChanged,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        );
      },
    );
  }
}
