import 'package:flutter/material.dart';

import '../../../models/musician_card_model.dart';
import '../../../../features/contacts/models/liked_musician.dart';
import '../../../../features/contacts/ui/widgets/musician_like_button.dart';

class MusiciansGrid extends StatelessWidget {
  const MusiciansGrid({super.key, required this.musicians});

  final List<MusicianCardModel> musicians;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final crossAxisCount = isCompact ? 1 : 2;
        const crossAxisSpacing = 12.0;
        const mainAxisSpacing = 12.0;
        final availableWidth =
            constraints.maxWidth - crossAxisSpacing * (crossAxisCount - 1);
        final tileWidth = availableWidth / crossAxisCount;
        final tileHeight = isCompact ? 112.0 : 128.0;
        final aspectRatio = tileWidth / tileHeight;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
          itemCount: musicians.length,
          itemBuilder: (context, index) {
            final musician = musicians[index];
            return _MusicianTile(musician: musician);
          },
        );
      },
    );
  }
}

class _MusicianTile extends StatelessWidget {
  const _MusicianTile({required this.musician});

  final MusicianCardModel musician;

  @override
  Widget build(BuildContext context) {
    final likedMusician = _mapToLiked();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            child: Text(musician.name.isNotEmpty ? musician.name[0] : '?'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  musician.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${musician.instrument} · ${musician.location}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 11, color: Colors.amber),
              Text(musician.rating.toStringAsFixed(1)),
              const SizedBox(height: 4),
              MusicianLikeButton(
                musician: likedMusician,
                iconSize: 20,
                constraints: const BoxConstraints(minHeight: 28, minWidth: 28),
              ),
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
