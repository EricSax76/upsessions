import 'package:flutter/material.dart';

class EmptyContacts extends StatelessWidget {
  const EmptyContacts({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 72, color: colorScheme.primary),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes contactos.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explora músicos y toca el corazón para guardarlos aquí.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

