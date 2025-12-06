import 'package:flutter/material.dart';

import '../../domain/musician_entity.dart';

class MusicianCard extends StatelessWidget {
  const MusicianCard({super.key, required this.musician, this.onTap});

  final MusicianEntity musician;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(musician.name.isNotEmpty ? musician.name[0] : '?')),
        title: Text(musician.name),
        subtitle: Text('${musician.instrument} · ${musician.city}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer),
            Text('${musician.experienceYears} años'),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
