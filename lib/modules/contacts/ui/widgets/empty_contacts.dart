import 'package:flutter/material.dart';

import '../../../../core/widgets/empty_state_card.dart';

class EmptyContacts extends StatelessWidget {
  const EmptyContacts({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: EmptyStateCard(
          icon: Icons.favorite_border,
          title: 'Aún no tienes contactos.',
          subtitle: 'Explora músicos y toca el corazón para guardarlos aquí.',
        ),
      ),
    );
  }
}

