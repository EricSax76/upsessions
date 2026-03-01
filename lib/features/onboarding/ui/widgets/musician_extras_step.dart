import 'package:flutter/material.dart';

import 'musician_onboarding_step_card.dart';
import 'premium_onboarding_textfield.dart';

class MusicianExtrasStep extends StatelessWidget {
  const MusicianExtrasStep({
    super.key,
    required this.formKey,
    required this.bioController,
    required this.onPickPhoto,
    this.selectedPhotoName,
    this.onClearPhoto,
    required this.availableForHire,
    required this.onAvailableForHireChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController bioController;
  final VoidCallback onPickPhoto;
  final String? selectedPhotoName;
  final VoidCallback? onClearPhoto;
  final bool availableForHire;
  final ValueChanged<bool> onAvailableForHireChanged;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        selectedPhotoName != null && selectedPhotoName!.trim().isNotEmpty;

    return Form(
      key: formKey,
      child: MusicianOnboardingStepCard(
        title: 'Tu sello personal',
        description:
            'Añade una foto o breve descripción para destacar en la comunidad.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: onPickPhoto,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Sube tu foto (galería y cámara)'),
            ),
            if (hasPhoto) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedPhotoName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (onClearPhoto != null)
                    IconButton(
                      onPressed: onClearPhoto,
                      icon: const Icon(Icons.close),
                      tooltip: 'Quitar foto',
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            PremiumOnboardingTextField(
              controller: bioController,
              hintText: 'Breve bio',
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Disponible para contratación'),
              subtitle: const Text('Márcalo si quieres que los organizadores puedan buscar tu perfil y contactarte para eventos.'),
              value: availableForHire,
              onChanged: onAvailableForHireChanged,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
