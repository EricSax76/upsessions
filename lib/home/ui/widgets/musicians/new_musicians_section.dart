import 'package:flutter/material.dart';

import '../../../../modules/musicians/models/musician_entity.dart';
import '../../../../core/widgets/sm_avatar.dart';

class NewMusiciansSection extends StatelessWidget {
  const NewMusiciansSection({super.key, required this.musicians});

  final List<MusicianEntity> musicians;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final listHeight = isCompact ? 120.0 : 100.0;
        final availableWidth = constraints.maxWidth == double.infinity
            ? 260.0
            : constraints.maxWidth;
        final cardWidth = isCompact
            ? (availableWidth * 0.7).clamp(180.0, 260.0)
            : 220.0;

        return SizedBox(
          height: listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: musicians.length,
            separatorBuilder: (context, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final musician = musicians[index];
              return SizedBox(
                width: cardWidth,
                child: _NewMusicianCard(musician: musician),
              );
            },
          ),
        );
      },
    );
  }
}

class _NewMusicianCard extends StatelessWidget {
  const _NewMusicianCard({required this.musician});

  final MusicianEntity musician;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            SmAvatar(
              radius: 28,
              imageUrl: musician.photoUrl,
              initials: musician.name.isNotEmpty ? musician.name[0] : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    musician.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    musician.instrument,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    musician.city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
