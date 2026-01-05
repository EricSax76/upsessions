import 'package:flutter/material.dart';

class MusicianContactCard extends StatelessWidget {
  const MusicianContactCard({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.onInvite,
  });

  final bool isLoading;
  final VoidCallback? onPressed;
  final VoidCallback? onInvite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Te interesa colaborar?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Conecta por chat para coordinar detalles y disponibilidad.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: onPressed,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.message_rounded),
                  label: Text(isLoading ? 'Abriendo...' : 'Contactar'),
                ),
                OutlinedButton.icon(
                  onPressed: onInvite,
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Invitar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
