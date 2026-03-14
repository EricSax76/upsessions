import 'package:flutter/material.dart';

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
                Chip(label: Text('Aforo ${venue.maxCapacity}')),
                Chip(label: Text(venue.isPublic ? 'Público' : 'Privado')),
                Chip(
                  label: Text(venue.isStudioBacked ? 'Studio sync' : 'Nativo'),
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
                child: const Text('Editar'),
              ),
              PopupMenuItem<_VenueAction>(
                value: _VenueAction.deactivate,
                enabled: canEdit,
                child: const Text('Desactivar'),
              ),
            ];
          },
        ),
      ),
    );
  }
}

enum _VenueAction { edit, deactivate }
