import 'package:flutter/material.dart';

import '../../../../features/contacts/ui/widgets/musician_like_button.dart';
import '../../../../modules/musicians/models/musician_entity.dart';
import '../../../../modules/musicians/models/musician_liked_musician_mapper.dart';

class MusiciansGrid extends StatelessWidget {
  const MusiciansGrid({super.key, required this.musicians});

  final List<MusicianEntity> musicians;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final crossAxisCount = isCompact ? 1 : 2;
        const crossAxisSpacing = 8.0;
        const mainAxisSpacing = 8.0;
        final availableWidth =
            constraints.maxWidth - crossAxisSpacing * (crossAxisCount - 1);
        final tileWidth = availableWidth / crossAxisCount;
        final tileHeight = isCompact ? 100.0 : 112.0;
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

  final MusicianEntity musician;

  @override
  Widget build(BuildContext context) {
    final likedMusician = musician.toLikedMusician();
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            child: Text(musician.name.isNotEmpty ? musician.name[0] : '?'),
          ),
          const SizedBox(width: 8),
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
                  '${musician.instrument} · ${musician.city}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 10, color: Colors.amber),
              Text((musician.rating ?? 0).toStringAsFixed(1)),
              const SizedBox(height: 2),
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
}
