import 'package:flutter/material.dart';

import '../../../data/musician_card_model.dart';

class MusiciansGrid extends StatelessWidget {
  const MusiciansGrid({super.key, required this.musicians});

  final List<MusicianCardModel> musicians;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final crossAxisCount = isCompact ? 1 : 2;
        final aspectRatio = isCompact ? 4.0 : 3.0;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              Text(musician.rating.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }
}
