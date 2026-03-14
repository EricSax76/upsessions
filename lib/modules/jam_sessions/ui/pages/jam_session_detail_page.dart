import 'package:flutter/material.dart';

import '../../../../core/locator/locator.dart';
import '../../../venues/models/venue_entity.dart';
import '../../../venues/repositories/venues_repository.dart';
import '../../models/jam_session_entity.dart';
import '../../repositories/jam_sessions_repository.dart';

class JamSessionDetailPage extends StatefulWidget {
  const JamSessionDetailPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  State<JamSessionDetailPage> createState() => _JamSessionDetailPageState();
}

class _JamSessionDetailPageState extends State<JamSessionDetailPage> {
  late final Future<_JamSessionDetailData?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadDetailData();
  }

  Future<_JamSessionDetailData?> _loadDetailData() async {
    final sessionsRepository = locate<JamSessionsRepository>();
    final venuesRepository = locate<VenuesRepository>();
    final session = await sessionsRepository.findById(widget.sessionId);
    if (session == null) return null;

    final venueId = (session.venueId ?? '').trim();
    if (venueId.isEmpty) {
      return _JamSessionDetailData(session: session, venue: null);
    }

    final venue = await venuesRepository.getVenueById(venueId);
    return _JamSessionDetailData(session: session, venue: venue);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_JamSessionDetailData?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return const Scaffold(
            body: Center(child: Text('Jam session no encontrada')),
          );
        }

        final session = data.session;
        final venue = data.venue;

        return Scaffold(
          appBar: AppBar(title: Text(session.title)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (session.coverImageUrl != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(session.coverImageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.music_note,
                      size: 64,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  session.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _locationLabel(session, venue),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _dateLabel(session),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Descripcion',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                      Chip(
                        label: Text('Edad minima: ${session.ageRestriction}+'),
                      ),
                    if ((session.venueId ?? '').trim().isNotEmpty)
                      const Chip(label: Text('Local asociado')),
                  ],
                ),
                if (venue != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Local',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(venue.name),
                  const SizedBox(height: 4),
                  Text(_venueAddressLabel(venue)),
                  const SizedBox(height: 4),
                  Text('Aforo del local: ${venue.maxCapacity}'),
                ],
                const SizedBox(height: 24),
                if (session.instrumentRequirements.isNotEmpty) ...[
                  Text(
                    'Se buscan instrumentistas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
          ),
        );
      },
    );
  }

  String _locationLabel(JamSessionEntity session, VenueEntity? venue) {
    if (venue != null) {
      final cityLabel = [
        venue.city.trim(),
        venue.province.trim(),
      ].where((part) => part.isNotEmpty).join(', ');
      if (cityLabel.isEmpty) return venue.name;
      return '$cityLabel • ${venue.name}';
    }

    final city = session.city.trim();
    final province = (session.province ?? '').trim();
    final location = session.location.trim();
    final cityLabel = [
      if (city.isNotEmpty) city,
      if (province.isNotEmpty) province,
    ].join(', ');
    if (cityLabel.isEmpty) return location;
    if (location.isEmpty) return cityLabel;
    return '$cityLabel • $location';
  }

  String _venueAddressLabel(VenueEntity venue) {
    final location = [
      venue.address.trim(),
      venue.city.trim(),
      venue.province.trim(),
      (venue.postalCode ?? '').trim(),
    ].where((part) => part.isNotEmpty).join(', ');
    if (location.isNotEmpty) {
      return location;
    }
    return 'Direccion no disponible';
  }

  String _dateLabel(JamSessionEntity session) {
    final date = session.date;
    final time = session.time.trim();
    if (date == null) return 'Fecha por definir';
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final yyyy = date.year.toString();
    if (time.isEmpty) return '$dd/$mm/$yyyy';
    return '$dd/$mm/$yyyy • $time';
  }
}

class _JamSessionDetailData {
  const _JamSessionDetailData({required this.session, required this.venue});

  final JamSessionEntity session;
  final VenueEntity? venue;
}
