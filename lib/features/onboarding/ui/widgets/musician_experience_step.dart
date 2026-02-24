import 'package:flutter/material.dart';

import 'musician_onboarding_step_card.dart';
import 'premium_onboarding_textfield.dart';

class MusicianExperienceStep extends StatelessWidget {
  const MusicianExperienceStep({
    super.key,
    required this.formKey,
    required this.yearsController,
    this.cityController,
    this.stylesController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController yearsController;
  final TextEditingController? cityController;
  final TextEditingController? stylesController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: MusicianOnboardingStepCard(
        title: 'Tu trayectoria musical',
        description:
            '¿Qué estilos te definen? Usa comas para separar varios estilos.',
        child: Column(
          children: [
            if (cityController != null)
              PremiumOnboardingTextField(
                controller: cityController!,
                hintText: 'Ciudad',
                textCapitalization: TextCapitalization.words,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ingresa tu ciudad'
                    : null,
              ),
            if (cityController != null) const SizedBox(height: 16),
            if (stylesController != null)
              PremiumOnboardingTextField(
                controller: stylesController!,
                hintText: 'Estilos (ej: Rock, Blues)',
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Al menos un estilo'
                    : null,
              ),
            if (stylesController != null) const SizedBox(height: 16),
            PremiumOnboardingTextField(
              controller: yearsController,
              hintText: 'Años de experiencia',
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
