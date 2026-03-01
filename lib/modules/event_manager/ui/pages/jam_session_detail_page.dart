import 'package:flutter/material.dart';

import '../../../../core/locator/locator.dart';
import '../../models/jam_session_entity.dart';
import '../../repositories/jam_sessions_repository.dart';

class JamSessionDetailPage extends StatelessWidget {
  const JamSessionDetailPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<JamSessionEntity?>(
      future: locate<JamSessionsRepository>().findById(sessionId),
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

        final session = snapshot.data;
        if (session == null) {
          return const Scaffold(
            body: Center(child: Text('Jam session no encontrada')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(session.title),
          ),
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
                  '${session.city} • ${session.location}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Descripción',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(session.description),
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
}
