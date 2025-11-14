import 'package:flutter/material.dart';

import '../../../data/musician_card_model.dart';

class MusiciansGrid extends StatelessWidget {
  const MusiciansGrid({super.key, required this.musicians});

  final List<MusicianCardModel> musicians;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: musicians.length,
      itemBuilder: (context, index) {
        final musician = musicians[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              CircleAvatar(child: Text(musician.name.isNotEmpty ? musician.name[0] : '?')),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(musician.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${musician.instrument} · ${musician.location}'),
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
      },
    );
  }
}
