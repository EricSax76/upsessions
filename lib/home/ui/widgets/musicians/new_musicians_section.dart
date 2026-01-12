import 'package:flutter/material.dart';

import '../../../models/musician_card_model.dart';
import '../../../../features/contacts/models/liked_musician.dart';
import '../../../../features/contacts/ui/widgets/musician_like_button.dart';

class NewMusiciansSection extends StatelessWidget {
  const NewMusiciansSection({super.key, required this.musicians});

  final List<MusicianCardModel> musicians;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final listHeight = isCompact ? 200.0 : 160.0;
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

  final MusicianCardModel musician;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final likedMusician = _mapToLiked();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            musician.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            musician.instrument,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Text(
                  musician.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              MusicianLikeButton(musician: likedMusician, iconSize: 20),
            ],
          ),
        ],
      ),
    );
  }

  LikedMusician _mapToLiked() {
    return LikedMusician(
      id: musician.id,
      ownerId: musician.ownerId,
      name: musician.name,
      instrument: musician.instrument,
      city: musician.location,
      styles: musician.styles,
      highlightStyle: musician.style,
      photoUrl: musician.avatarUrl,
      experienceYears: musician.experienceYears,
      rating: musician.rating,
    );
  }
}
