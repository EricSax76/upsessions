import 'package:flutter/material.dart';

import '../../controllers/musician_onboarding_controller.dart';
import '../musician_onboarding_step_card.dart';

class MusicianBasicInfoStep extends StatelessWidget {
  const MusicianBasicInfoStep({super.key, required this.controller});

  final MusicianOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.basicInfoKey,
      child: MusicianOnboardingStepCard(
        title: 'Tu identidad musical',
        description:
            'Comparte tu nombre artístico y el/los instrumento/S que tocas.',
        child: Column(
          children: [
            TextFormField(
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: 'Nombre artístico'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Ingresa tu nombre'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.instrumentController,
              decoration: const InputDecoration(
                labelText: 'Instrumento principal',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Indica tu instrumento'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
