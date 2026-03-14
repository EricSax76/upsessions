import 'package:flutter/material.dart';

import '../../../../venues/models/venue_entity.dart';

class JamSessionVenueSection extends StatelessWidget {
  const JamSessionVenueSection({
    super.key,
    required this.useRegisteredVenue,
    required this.isLoadingVenues,
    required this.venuesError,
    required this.venues,
    required this.selectedVenueId,
    required this.onToggleUseRegisteredVenue,
    required this.onVenueSelected,
    required this.onRetryLoadVenues,
  });

  final bool useRegisteredVenue;
  final bool isLoadingVenues;
  final String? venuesError;
  final List<VenueEntity> venues;
  final String? selectedVenueId;
  final ValueChanged<bool> onToggleUseRegisteredVenue;
  final ValueChanged<String?> onVenueSelected;
  final VoidCallback onRetryLoadVenues;

  @override
  Widget build(BuildContext context) {
    final hasVenues = venues.isNotEmpty;
    final canUseRegisteredVenue = !isLoadingVenues && hasVenues;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: useRegisteredVenue && canUseRegisteredVenue,
                title: const Text('Asociar a local registrado'),
                subtitle: const Text(
                  'Usa un local del catalogo para trazabilidad y consistencia.',
                ),
                onChanged: canUseRegisteredVenue
                    ? onToggleUseRegisteredVenue
                    : null,
              ),
            ),
            if (isLoadingVenues)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        if (venuesError != null) ...[
          const SizedBox(height: 8),
          Text(
            venuesError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onRetryLoadVenues,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar carga'),
            ),
          ),
        ],
        if (useRegisteredVenue && canUseRegisteredVenue) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey('venue-$selectedVenueId-${venues.length}'),
            initialValue: selectedVenueId,
            decoration: const InputDecoration(labelText: 'Local asociado'),
            items: venues
                .map(
                  (venue) => DropdownMenuItem<String>(
                    value: venue.id,
                    child: Text('${venue.name} (${venue.city})'),
                  ),
                )
                .toList(),
            onChanged: onVenueSelected,
            validator: (value) {
              if (useRegisteredVenue &&
                  (value == null || value.trim().isEmpty)) {
                return 'Selecciona un local';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}
