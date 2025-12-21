import 'package:flutter/material.dart';

import '../../domain/musician_entity.dart';
import '../../../../features/contacts/domain/liked_musician.dart';
import '../../../../features/contacts/presentation/widgets/musician_like_button.dart';

class MusicianCard extends StatelessWidget {
  const MusicianCard({super.key, required this.musician, this.onTap});

  final MusicianEntity musician;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final likedMusician = LikedMusician(
      id: musician.id,
      ownerId: musician.ownerId,
      name: musician.name,
      instrument: musician.instrument,
      city: musician.city,
      styles: musician.styles,
      highlightStyle: musician.styles.isNotEmpty ? musician.styles.first : null,
      photoUrl: musician.photoUrl,
      experienceYears: musician.experienceYears,
    );
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(musician.name.isNotEmpty ? musician.name[0] : '?'),
        ),
        title: Text(musician.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${musician.instrument} · ${musician.city}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.timer, size: 16),
                const SizedBox(width: 4),
                Text('${musician.experienceYears} años'),
              ],
            ),
          ],
        ),
        trailing: MusicianLikeButton(musician: likedMusician, iconSize: 20),
        onTap: onTap,
      ),
    );
  }
}
