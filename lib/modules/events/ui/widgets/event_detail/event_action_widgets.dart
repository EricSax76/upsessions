import 'package:flutter/material.dart';

import '../../../../../core/widgets/empty_state_card.dart';

class EventQuickActionsSection extends StatelessWidget {
  const EventQuickActionsSection({super.key, required this.onCopyTemplate});

  final Future<void> Function() onCopyTemplate;

  @override
  Widget build(BuildContext context) {
    return EmptyStateCard(
      icon: Icons.tips_and_updates_outlined,
      title: 'Acciones rápidas',
      subtitle: 'Comparte o copia la ficha del evento en texto.',
      trailing: IconButton(
        tooltip: 'Copiar formato',
        onPressed: () => onCopyTemplate(),
        icon: const Icon(Icons.copy_all_outlined),
      ),
    );
  }
}

class EventActionButtons extends StatelessWidget {
  const EventActionButtons({
    super.key,
    required this.onShare,
    required this.onCopyTemplate,
  });

  final VoidCallback onShare;
  final Future<void> Function() onCopyTemplate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Compartir ficha'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => onCopyTemplate(),
            icon: const Icon(Icons.copy_all_outlined),
            label: const Text('Copiar formato'),
          ),
        ),
      ],
    );
  }
}
