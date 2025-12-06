import 'package:flutter/material.dart';

import 'package:upsessions/home/data/models/musician_card_model.dart';
import 'musicians_grid.dart';

class RecommendedUsersSection extends StatelessWidget {
  const RecommendedUsersSection({super.key, required this.musicians});

  final List<MusicianCardModel> musicians;

  @override
  Widget build(BuildContext context) {
    if (musicians.isEmpty) {
      return const Text('No hay recomendaciones por ahora.');
    }
    return MusiciansGrid(musicians: musicians);
  }
}
