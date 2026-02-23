import 'package:flutter/material.dart';

class ContactCardActions extends StatelessWidget {
  const ContactCardActions({
    super.key,
    required this.onViewProfile,
    required this.onContact,
    required this.isContacting,
  });

  final VoidCallback onViewProfile;
  final VoidCallback onContact;
  final bool isContacting;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onViewProfile,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: const Text('Ver perfil'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: isContacting ? null : onContact,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
            icon: isContacting
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            label: Text(
              isContacting ? '...' : 'Contactar',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
