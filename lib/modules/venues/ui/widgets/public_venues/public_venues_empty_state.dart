import 'package:flutter/material.dart';

class PublicVenuesEmptyState extends StatelessWidget {
  const PublicVenuesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No hay locales disponibles con los filtros aplicados.',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}
