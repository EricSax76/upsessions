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
        return LayoutBuilder(
          builder: (context, constraints) {
            // Calcular número de columnas según el ancho disponible
            // (después de restar el panel de filtros lateral)
            int crossAxisCount;
            double cardWidth;
            
            if (constraints.maxWidth >= 900) {
              // Vista web completa: 3 cards
              crossAxisCount = 3;
              cardWidth = (constraints.maxWidth - 48) / 3; // 48 = spacing
            } else if (constraints.maxWidth >= 500) {
              // Vista medium: 2 cards
              crossAxisCount = 2;
              cardWidth = (constraints.maxWidth - 32) / 2; // 32 = spacing
            } else {
              // Vista reducida: 1 card
              crossAxisCount = 1;
              cardWidth = constraints.maxWidth - 16; // 16 = spacing
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: cardWidth / 280, // Altura fija de ~280px por card
              ),
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
      },
    );
  }
}
