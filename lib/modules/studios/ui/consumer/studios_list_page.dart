import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../cubits/studios_list_cubit.dart';
import '../../cubits/studios_list_state.dart';
import '../../cubits/studios_status.dart';
import '../../models/studio_entity.dart';
import '../../repositories/studios_repository.dart';
import 'rehearsal_booking_context.dart';
import 'widgets/studio_card.dart';

class StudiosListPage extends StatelessWidget {
  const StudiosListPage({super.key, this.rehearsalContext});

  final RehearsalBookingContext? rehearsalContext;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) =>
          StudiosListCubit(repository: locate<StudiosRepository>())
            ..loadAllStudios(refresh: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              rehearsalContext != null
                  ? loc.studiosListTitleForRehearsal
                  : loc.studios,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: BlocBuilder<StudiosListCubit, StudiosListState>(
              builder: (context, state) {
                if (state.status == StudiosStatus.loading &&
                    state.studios.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.studios.isEmpty) {
                  return Center(child: Text(loc.studiosListEmpty));
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        final loadMore = _LoadMoreStudiosFooter(state: state);
                        Future<void> onRefresh() => context
                            .read<StudiosListCubit>()
                            .loadAllStudios(refresh: true);

                        if (isWide) {
                          return Column(
                            children: [
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: onRefresh,
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(24),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          mainAxisExtent: 280,
                                        ),
                                    itemCount: state.studios.length,
                                    itemBuilder: (context, index) {
                                      final studio = state.studios[index];
                                      return StudioCard(
                                        studio: studio,
                                        onTap: () =>
                                            _navigateToRooms(context, studio),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              loadMore,
                            ],
                          );
                        }

                        return Column(
                          children: [
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: onRefresh,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: state.studios.length,
                                  itemBuilder: (context, index) {
                                    final studio = state.studios[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: StudioCard(
                                        studio: studio,
                                        onTap: () =>
                                            _navigateToRooms(context, studio),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            loadMore,
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRooms(BuildContext context, StudioEntity studio) {
    context.push(
      AppRoutes.studiosRoomsPath(studio.id),
      extra: rehearsalContext,
    );
  }
}

class _LoadMoreStudiosFooter extends StatelessWidget {
  const _LoadMoreStudiosFooter({required this.state});

  final StudiosListState state;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (state.isLoadingStudiosMore) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: CircularProgressIndicator(),
      );
    }
    if (!state.hasMoreStudios) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: OutlinedButton.icon(
        onPressed: () => context.read<StudiosListCubit>().loadAllStudios(),
        icon: const Icon(Icons.expand_more),
        label: Text(loc.studiosListLoadMore),
      ),
    );
  }
}
