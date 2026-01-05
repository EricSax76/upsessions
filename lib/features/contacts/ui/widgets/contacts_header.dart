import 'package:flutter/material.dart';

class ContactsHeader extends StatelessWidget {
  const ContactsHeader({super.key, required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contactos',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          total == 1
              ? 'Tienes 1 músico guardado.'
              : 'Tienes $total músicos guardados.',
        ),
      ],
    );
  }
}

