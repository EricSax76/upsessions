import 'package:flutter/material.dart';

import '../../../../core/locator/locator.dart';
import '../../../venues/models/venue_entity.dart';
import '../../../venues/repositories/venues_repository.dart';
import '../../models/jam_session_entity.dart';
import '../../repositories/jam_sessions_repository.dart';
import '../widgets/detail/jam_session_detail_content.dart';

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

        return Scaffold(
          appBar: AppBar(title: Text(data.session.title)),
          body: JamSessionDetailContent(
            session: data.session,
            venue: data.venue,
          ),
        );
      },
    );
  }
}

class _JamSessionDetailData {
  const _JamSessionDetailData({required this.session, required this.venue});

  final JamSessionEntity session;
  final VenueEntity? venue;
}
