import 'package:flutter/material.dart';

import '../../models/musician_onboarding_controller.dart';
import 'musician_onboarding_step_card.dart';

class MusicianExtrasStep extends StatelessWidget {
  const MusicianExtrasStep({super.key, required this.controller});

  final MusicianOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.extrasKey,
      child: MusicianOnboardingStepCard(
        title: 'Tu sello personal',
        description:
            'Añade una foto o breve descripción para destacar en la comunidad.',
        child: Column(
          children: [
            TextFormField(
              controller: controller.photoUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de tu foto (opcional)',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.bioController,
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
