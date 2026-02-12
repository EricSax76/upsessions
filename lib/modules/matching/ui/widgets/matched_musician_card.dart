import 'package:flutter/material.dart';
import '../../repositories/matching_repository.dart';

class MatchedMusicianCard extends StatelessWidget {
  const MatchedMusicianCard({super.key, required this.match, this.onTap});

  final MatchingResult match;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Reuse the existing MusicianCard for the base profile
    // But we probably want to wrap it or add content below it.
    // Since MusicianCard is a card, putting it inside a Column inside another Card is ugly.
    
    // Better approach: Reimplement the card UI to include the match info nicely,
    // OR create a custom widget that uses MusicianCard as a header.
    
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
       color: colors.surfaceContainerLow,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // We can embed the MusicianCard content here, or simpler:
            // Just use MusicianCard but ignore its tap, and wrap it?
            // No, MusicianCard has its own Card decoration.
            
            // Let's build a custom card that mimics MusicianCard but adds the influences section.
            // For simplicity and consistency, I'll rely on MusicianCard visuals but 
            // I'll put the "Shared Influences" in a special container at the bottom.
            
            // Actually, `MusicianCard` is designed as a standalone card. 
            // If I put it in a column, it will look like a card in a column.
            
            // Design:
            // [ Musician Card Content (Name, Instrument, Location) ]
            // [ Separator ]
            // [ Shared Influences Section ]
            
            // To achieve this without code duplication, I would need to refactor MusicianCard.
            // But I can't change MusicianCard easily without affecting other parts.
            // So I will create a new layout specific for matches.
            
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
                           style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                         ),
                         Text(
                           '${match.musician.instrument} • ${match.musician.city}',
                           style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                         ),
                       ],
                     ),
                   ),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                     decoration: BoxDecoration(
                       color: colors.tertiaryContainer,
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: Text(
                       // The repository returns raw points, so show points explicitly.
                       // The repo returns raw points. Let's just show "High Match" or the points.
                       // Or simple "Match".
                       // The user request didn't specify score display.
                       // Let's show the points as a score.
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
                            style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurface),
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
      ),
    );
  }
}
