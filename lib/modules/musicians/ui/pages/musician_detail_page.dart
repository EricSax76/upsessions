import 'package:flutter/material.dart';

import '../../domain/musician_entity.dart';

class MusicianDetailPage extends StatelessWidget {
  const MusicianDetailPage({super.key, required this.musician});

  final MusicianEntity musician;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(musician.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${musician.instrument} · ${musician.city}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: musician.styles.map((style) => Chip(label: Text(style))).toList()),
            const SizedBox(height: 12),
            Text('Experiencia: ${musician.experienceYears} años'),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.message),
              label: const Text('Contactar'),
            ),
          ],
        ),
      ),
    );
  }
}
