import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/modules/profile/cubit/profile_form_cubit.dart';

class ProfileBasicInfoFields extends StatelessWidget {
  const ProfileBasicInfoFields({super.key});

  @override
  Widget build(BuildContext context) {
    // We access the cubit directly as it should be provided by the parent ProfileForm
    final cubit = context.read<ProfileFormCubit>();

    return BlocBuilder<ProfileFormCubit, ProfileFormState>(
      buildWhen: (previous, current) =>
          previous.bio != current.bio ||
          previous.location != current.location ||
          previous.availableForHire != current.availableForHire,
      builder: (context, state) {
        return Column(
          children: [
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
            SwitchListTile(
              title: const Text('Disponible para contratación'),
              subtitle: const Text('Márcalo si quieres que los organizadores puedan buscar tu perfil y contactarte para eventos.'),
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
