import 'package:flutter/material.dart';

class PublicVenuesFilters extends StatelessWidget {
  const PublicVenuesFilters({
    super.key,
    required this.cityController,
    required this.provinceController,
    required this.isLoading,
    required this.onApply,
  });

  final TextEditingController cityController;
  final TextEditingController provinceController;
  final bool isLoading;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final filterAction = FilledButton.icon(
      onPressed: isLoading ? null : onApply,
      icon: const Icon(Icons.search),
      label: const Text('Filtrar'),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'Ciudad'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: provinceController,
                  decoration: const InputDecoration(labelText: 'Provincia'),
                ),
                const SizedBox(height: 12),
                filterAction,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'Ciudad'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: provinceController,
                  decoration: const InputDecoration(labelText: 'Provincia'),
                ),
              ),
              const SizedBox(width: 12),
              filterAction,
            ],
          );
        },
      ),
    );
  }
}
