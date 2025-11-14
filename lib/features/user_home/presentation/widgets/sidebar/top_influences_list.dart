import 'package:flutter/material.dart';

class TopInfluencesList extends StatelessWidget {
  const TopInfluencesList({super.key});

  static const _influences = ['Bjork', 'Beyoncé', 'Zoé', 'Soda Stereo'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Influencias principales', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _influences.map((name) => Chip(label: Text(name))).toList(),
        ),
      ],
    );
  }
}
