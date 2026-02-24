import 'package:flutter/material.dart';
import '../widgets/musician_onboarding_step_card.dart';
import '../widgets/premium_onboarding_textfield.dart';

class MusicianIdentityStep extends StatelessWidget {
  const MusicianIdentityStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.instrumentController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController instrumentController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: MusicianOnboardingStepCard(
        title: 'Tu identidad musical',
        description: 'Comparte tu nombre artístico y el/los instrumento/s que tocas.',
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
          ],
        ),
      ),
    );
  }
}
