import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/modules/matching/cubits/matching_cubit.dart';
import '../widgets/matched_musician_card.dart';

class MatchingPage extends StatelessWidget {
  const MatchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MatchingCubit()..loadMatches(),
      child: Column(
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
            child: BlocBuilder<MatchingCubit, MatchingState>(
              builder: (context, state) {
                if (state.status == MatchingStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == MatchingStatus.failure) {
                  return Center(
                    child: Text('Error: ${state.errorMessage}'),
                  );
                }

                final matches = state.matches;

                if (matches.isEmpty && state.status == MatchingStatus.success) {
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
      ),
    );
  }
}
