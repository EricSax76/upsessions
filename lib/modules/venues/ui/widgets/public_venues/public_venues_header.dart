import 'package:flutter/material.dart';

class PublicVenuesHeader extends StatelessWidget {
  const PublicVenuesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        'Locales de espectáculos',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
