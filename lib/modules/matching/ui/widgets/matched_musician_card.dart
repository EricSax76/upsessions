import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../repositories/matching_repository.dart';

class MatchedMusicianCard extends StatelessWidget {
  const MatchedMusicianCard({super.key, required this.match, this.onTap});

  final MatchingResult match;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppCard(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: colors.surfaceContainerLow,
      padding: EdgeInsets.zero, // Let the child handle padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colors.primaryContainer,
                  backgroundImage: match.musician.photoUrl != null
                      ? NetworkImage(match.musician.photoUrl!)
                      : null,
                  child: match.musician.photoUrl == null
                      ? Text(match.musician.name.characters.first)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.musician.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${match.musician.instrument} • ${match.musician.city}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${match.score} pts',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (match.sharedInfluences.isNotEmpty) ...[
            Divider(height: 1, color: colors.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Influencias en común',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...match.sharedInfluences.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: colors.onSurface),
                          children: [
                            TextSpan(
                              text: '${entry.key}: ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: entry.value.join(', ')),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
