import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/musician_search_cubit.dart';
import '../../../models/musician_entity.dart';
import '../musicians/musician_card.dart';

class MusicianSearchResultsList extends StatelessWidget {
  const MusicianSearchResultsList({super.key, required this.onTapMusician});

  final ValueChanged<MusicianEntity> onTapMusician;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicianSearchCubit, MusicianSearchState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.errorMessage != null) {
          return Center(
            child: Text(
              state.errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
            ),
          );
        }
        if (state.results.isEmpty) {
          return const Center(
            child: Text('No encontramos músicos con esos filtros.'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: state.results.length,
          itemBuilder: (context, index) {
            final musician = state.results[index];
            return MusicianCard(
              musician: musician,
              onTap: () => onTapMusician(musician),
            );
          },
        );
      },
    );
  }
}
