import 'package:flutter/material.dart';

import 'musician_onboarding_step_card.dart';

class MusicianExtrasStep extends StatelessWidget {
  const MusicianExtrasStep({
    super.key,
    required this.formKey,
    required this.photoUrlController,
    required this.bioController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController photoUrlController;
  final TextEditingController bioController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: MusicianOnboardingStepCard(
        title: 'Tu sello personal',
        description:
            'Añade una foto o breve descripción para destacar en la comunidad.',
        child: Column(
          children: [
            TextFormField(
              controller: photoUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de tu foto (opcional)',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: bioController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Breve bio (opcional)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
