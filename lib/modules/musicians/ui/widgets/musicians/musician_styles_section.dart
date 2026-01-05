import 'package:flutter/material.dart';

class MusicianStylesSection extends StatelessWidget {
  const MusicianStylesSection({super.key, required this.styles});

  final List<String> styles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estilos musicales',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (styles.isEmpty)
              Text(
                'Este músico aún no especificó estilos.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: styles
                    .map(
                      (style) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: colors.primary.withValues(),
                        ),
                        child: Text(
                          style,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
