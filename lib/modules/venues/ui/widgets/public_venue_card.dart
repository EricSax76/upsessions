import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../models/venue_entity.dart';

class PublicVenueCard extends StatelessWidget {
  const PublicVenueCard({super.key, required this.venue});

  final VenueEntity venue;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              venue.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '${venue.city} • ${venue.province}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(venue.address, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    localizations.venueCardCapacityLabel(venue.maxCapacity),
                  ),
                ),
                if (venue.accessibilityInfo.trim().isNotEmpty)
                  Chip(label: Text(venue.accessibilityInfo.trim())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
