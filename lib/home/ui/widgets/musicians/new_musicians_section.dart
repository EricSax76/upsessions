import 'package:flutter/material.dart';

import '../../../data/models/musician_card_model.dart';

class NewMusiciansSection extends StatelessWidget {
  const NewMusiciansSection({super.key, required this.musicians});

  final List<MusicianCardModel> musicians;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: musicians.length,
        separatorBuilder: (context, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final musician = musicians[index];
          return Container(
            width: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  musician.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(musician.instrument),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(musician.location),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
