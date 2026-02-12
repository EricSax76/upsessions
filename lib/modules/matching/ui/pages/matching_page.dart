import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/matching/repositories/matching_repository.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import '../widgets/matched_musician_card.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  late Future<List<MatchingResult>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _loadMatches();
  }

  Future<List<MatchingResult>> _loadMatches() async {
    final authRepo = context.read<AuthRepository>();
    final user = authRepo.currentUser;
    if (user == null) return [];

    final musiciansRepo = context.read<MusiciansRepository>();
    final myProfile = await musiciansRepo.findById(user.id);

    if (myProfile == null || myProfile.influences.isEmpty) {
      return [];
    }

    final matchingRepo = MatchingRepository();
    return matchingRepo.findMatches(
      myInfluences: myProfile.influences,
      myId: user.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Text(
            'Tu afinidad musical',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<MatchingResult>>(
            future: _matchesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final matches = snapshot.data ?? [];

              if (matches.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.music_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No encontramos coincidencias aún.',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Asegúrate de agregar tus influencias en tu perfil para encontrar músicos afines.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: matches.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return MatchedMusicianCard(
                    match: match,
                    onTap: () {
                      context.push(
                        AppRoutes.musicianDetailPath(
                          musicianId: match.musician.id,
                          musicianName: match.musician.name,
                        ),
                        extra: match.musician,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
