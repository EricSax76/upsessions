import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context);
    final filterAction = FilledButton.icon(
      onPressed: isLoading ? null : onApply,
      icon: const Icon(Icons.search),
      label: Text(localizations.venueFiltersApply),
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
                  decoration: InputDecoration(
                    labelText: localizations.venueFieldCity,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: provinceController,
                  decoration: InputDecoration(
                    labelText: localizations.venueFieldProvince,
                  ),
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
                  decoration: InputDecoration(
                    labelText: localizations.venueFieldCity,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: provinceController,
                  decoration: InputDecoration(
                    labelText: localizations.venueFieldProvince,
                  ),
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
