import 'package:flutter/material.dart';

import '../../../../venues/models/venue_entity.dart';
import '../../../models/jam_session_entity.dart';
import 'jam_session_detail_banner.dart';
import 'jam_session_detail_helpers.dart';

class JamSessionDetailContent extends StatelessWidget {
  const JamSessionDetailContent({
    super.key,
    required this.session,
    required this.venue,
  });

  final JamSessionEntity session;
  final VenueEntity? venue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          JamSessionDetailBanner(coverImageUrl: session.coverImageUrl),
          const SizedBox(height: 24),
          Text(
            session.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            buildJamSessionLocationLabel(session, venue),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatJamSessionDate(session.date, session.time),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            'Descripcion',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(session.description),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(session.isPublic ? 'Publica' : 'Privada')),
              if (session.maxAttendees != null)
                Chip(label: Text('Aforo: ${session.maxAttendees}')),
              if (session.entryFee != null)
                Chip(label: Text('Entrada: ${session.entryFee} EUR')),
              if (session.ageRestriction != null)
                Chip(label: Text('Edad minima: ${session.ageRestriction}+')),
              if ((session.venueId ?? '').trim().isNotEmpty)
                const Chip(label: Text('Local asociado')),
            ],
          ),
          if (venue != null) ...[
            const SizedBox(height: 24),
            Text(
              'Local',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(venue!.name),
            const SizedBox(height: 4),
            Text(buildVenueAddressLabel(venue!)),
            const SizedBox(height: 4),
            Text('Aforo del local: ${venue!.maxCapacity}'),
          ],
          if (session.instrumentRequirements.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Se buscan instrumentistas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: session.instrumentRequirements
                  .map((inst) => Chip(label: Text(inst)))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
