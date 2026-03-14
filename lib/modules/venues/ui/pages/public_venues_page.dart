import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/public_venues_cubit.dart';
import '../../cubits/public_venues_state.dart';
import '../widgets/public_venue_card.dart';

class PublicVenuesPage extends StatefulWidget {
  const PublicVenuesPage({super.key});

  @override
  State<PublicVenuesPage> createState() => _PublicVenuesPageState();
}

class _PublicVenuesPageState extends State<PublicVenuesPage> {
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PublicVenuesCubit>().loadVenues();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicVenuesCubit, PublicVenuesState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'Locales de espectáculos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: _buildFilters(context, state),
            ),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildFilters(BuildContext context, PublicVenuesState state) {
    final filterAction = FilledButton.icon(
      onPressed: state.isLoading
          ? null
          : () {
              context.read<PublicVenuesCubit>().applyFilters(
                city: _cityController.text,
                province: _provinceController.text,
              );
            },
      icon: const Icon(Icons.search),
      label: const Text('Filtrar'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Ciudad'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _provinceController,
                decoration: const InputDecoration(labelText: 'Provincia'),
              ),
              const SizedBox(height: 12),
              filterAction,
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Ciudad'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _provinceController,
                decoration: const InputDecoration(labelText: 'Provincia'),
              ),
            ),
            const SizedBox(width: 12),
            filterAction,
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PublicVenuesState state) {
    if (state.isLoading && state.venues.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.venues.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    context.read<PublicVenuesCubit>().loadVenues(refresh: true),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.venues.isEmpty) {
      return Center(
        child: Text(
          'No hay locales disponibles con los filtros aplicados.',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      itemCount: state.venues.length + 1,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == state.venues.length) {
          if (!state.hasMore) return const SizedBox.shrink();
          return Align(
            alignment: Alignment.center,
            child: OutlinedButton.icon(
              onPressed: state.isLoadingMore
                  ? null
                  : () => context.read<PublicVenuesCubit>().loadMore(),
              icon: state.isLoadingMore
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.expand_more),
              label: const Text('Cargar más'),
            ),
          );
        }

        return PublicVenueCard(venue: state.venues[index]);
      },
    );
  }
}
