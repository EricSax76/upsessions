import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_routes.dart';
import '../../cubits/manager_venues_cubit.dart';
import '../../cubits/manager_venues_state.dart';
import '../../models/venue_entity.dart';
import '../widgets/manager_venues/manager_venues_empty_state.dart';
import '../widgets/manager_venues/manager_venues_error_state.dart';
import '../widgets/manager_venues/manager_venues_list.dart';

class ManagerVenuesPage extends StatefulWidget {
  const ManagerVenuesPage({
    super.key,
    this.createVenueRoute = AppRoutes.eventManagerVenueForm,
    this.editVenueRoutePathBuilder = AppRoutes.eventManagerVenueEditPath,
    this.headingTitle,
  });

  final String createVenueRoute;
  final String Function(String venueId) editVenueRoutePathBuilder;
  final String? headingTitle;

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
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(localizations.venueManagerDeactivateTitle),
          content: Text(
            localizations.venueManagerDeactivateMessage(venue.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(localizations.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(localizations.venueManagerDeactivateAction),
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
    final localizations = AppLocalizations.of(context);
    final headingTitle =
        widget.headingTitle ?? localizations.venueManagerHeadingTitle;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateVenue,
        icon: const Icon(Icons.add_business),
        label: Text(localizations.venueManagerNewVenue),
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
            return ManagerVenuesErrorState(
              message: state.errorMessage!,
              onRetry: () =>
                  context.read<ManagerVenuesCubit>().loadVenues(refresh: true),
            );
          }

          if (state.venues.isEmpty) {
            return const ManagerVenuesEmptyState();
          }

          return ManagerVenuesList(
            headingTitle: headingTitle,
            venues: state.venues,
            hasMore: state.hasMore,
            isLoadingMore: state.isLoadingMore,
            onLoadMore: () => context.read<ManagerVenuesCubit>().loadMore(),
            onEdit: _openEditVenue,
            onDeactivate: _confirmDeactivate,
          );
        },
      ),
    );
  }
}
