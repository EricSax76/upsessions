import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../models/venue_entity.dart';

class ManagerVenueCard extends StatelessWidget {
  const ManagerVenueCard({
    super.key,
    required this.venue,
    required this.onTap,
    required this.onEdit,
    required this.onDeactivate,
  });

  final VenueEntity venue;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final canEdit = !venue.isStudioBacked;

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          child: Icon(venue.isStudioBacked ? Icons.sync : Icons.place_outlined),
        ),
        title: Text(
          venue.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${venue.city} • ${venue.province}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Chip(
                  label: Text(
                    localizations.venueCardCapacityLabel(venue.maxCapacity),
                  ),
                ),
                Chip(
                  label: Text(
                    venue.isPublic
                        ? localizations.venueCardPublic
                        : localizations.venueCardPrivate,
                  ),
                ),
                Chip(
                  label: Text(
                    venue.isStudioBacked
                        ? localizations.venueCardSourceStudioSync
                        : localizations.venueCardSourceNative,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<_VenueAction>(
          onSelected: (action) {
            if (action == _VenueAction.edit) onEdit();
            if (action == _VenueAction.deactivate) onDeactivate();
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem<_VenueAction>(
                value: _VenueAction.edit,
                enabled: canEdit,
                child: Text(localizations.venueCardEdit),
              ),
              PopupMenuItem<_VenueAction>(
                value: _VenueAction.deactivate,
                enabled: canEdit,
                child: Text(localizations.venueCardDeactivate),
              ),
            ];
          },
        ),
      ),
    );
  }
}

enum _VenueAction { edit, deactivate }
