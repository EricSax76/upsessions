import 'package:flutter/material.dart';

import '../../models/musician_onboarding_controller.dart';
import 'musician_onboarding_step_card.dart';

class MusicianExperienceStep extends StatelessWidget {
  const MusicianExperienceStep({super.key, required this.controller});

  final MusicianOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.experienceKey,
      child: MusicianOnboardingStepCard(
        title: 'Tu trayectoria musical',
        description:
            '¿Qué estilos te definen? Usa comas para separar varios estilos.',
        child: Column(
          children: [
            TextFormField(
              controller: controller.cityController,
              decoration: const InputDecoration(labelText: 'Ciudad'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Ingresa tu ciudad'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.stylesController,
              decoration: const InputDecoration(
                labelText: 'Estilos (ej: Rock, Blues)',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Al menos un estilo'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.yearsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Años de experiencia',
              ),
              validator: (value) {
                final parsed = int.tryParse(value ?? '');
                if (parsed == null || parsed < 0) {
                  return 'Ingresa un número válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
