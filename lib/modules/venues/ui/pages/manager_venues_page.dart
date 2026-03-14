import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../cubits/manager_venues_cubit.dart';
import '../../cubits/manager_venues_state.dart';
import '../../models/venue_entity.dart';
import '../widgets/manager_venue_card.dart';

class ManagerVenuesPage extends StatefulWidget {
  const ManagerVenuesPage({
    super.key,
    this.createVenueRoute = AppRoutes.eventManagerVenueForm,
    this.editVenueRoutePathBuilder = AppRoutes.eventManagerVenueEditPath,
    this.headingTitle = 'Mis Locales',
  });

  final String createVenueRoute;
  final String Function(String venueId) editVenueRoutePathBuilder;
  final String headingTitle;

  @override
  State<ManagerVenuesPage> createState() => _ManagerVenuesPageState();
}

class _ManagerVenuesPageState extends State<ManagerVenuesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ManagerVenuesCubit>().loadVenues();
  }

  Future<void> _openCreateVenue() async {
    final created = await context.push(widget.createVenueRoute);
    if (!mounted || created != true) return;
    context.read<ManagerVenuesCubit>().loadVenues(refresh: true);
  }

  Future<void> _openEditVenue(VenueEntity venue) async {
    final updated = await context.push(
      widget.editVenueRoutePathBuilder(venue.id),
      extra: venue,
    );
    if (!mounted || updated != true) return;
    context.read<ManagerVenuesCubit>().loadVenues(refresh: true);
  }

  Future<void> _confirmDeactivate(VenueEntity venue) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Desactivar local'),
          content: Text('¿Quieres desactivar "${venue.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;
    await context.read<ManagerVenuesCubit>().deactivateVenue(venue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateVenue,
        icon: const Icon(Icons.add_business),
        label: const Text('Nuevo Local'),
      ),
      body: BlocConsumer<ManagerVenuesCubit, ManagerVenuesState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null &&
            current.venues.isNotEmpty,
        listener: (context, state) {
          final message = state.errorMessage;
          if (message == null) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context
                          .read<ManagerVenuesCubit>()
                          .loadVenues(refresh: true),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.venues.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes locales activos.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: state.venues.length + 2,
            separatorBuilder: (context, index) {
              if (index == 0 || index == state.venues.length + 1) {
                return const SizedBox.shrink();
              }
              return const SizedBox(height: 10);
            },
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    widget.headingTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              if (index == state.venues.length + 1) {
                if (!state.hasMore) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Align(
                    alignment: Alignment.center,
                    child: OutlinedButton.icon(
                      onPressed: state.isLoadingMore
                          ? null
                          : () => context.read<ManagerVenuesCubit>().loadMore(),
                      icon: state.isLoadingMore
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.expand_more),
                      label: const Text('Cargar más'),
                    ),
                  ),
                );
              }

              final venue = state.venues[index - 1];
              return ManagerVenueCard(
                venue: venue,
                onTap: () => _openEditVenue(venue),
                onEdit: () => _openEditVenue(venue),
                onDeactivate: () => _confirmDeactivate(venue),
              );
            },
          );
        },
      ),
    );
  }
}
