import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../models/room_entity.dart';
import '../../models/studio_entity.dart';
import 'widgets/room_card.dart';
import 'widgets/studio_card.dart';
import '../../repositories/studios_repository.dart';
import '../../services/studio_image_service.dart';
import '../../../../core/locator/locator.dart';

/// Context for booking from a rehearsal
class RehearsalBookingContext {
  const RehearsalBookingContext({
    required this.groupId,
    required this.rehearsalId,
    required this.suggestedDate,
    this.suggestedEndDate,
  });

  final String groupId;
  final String rehearsalId;
  final DateTime suggestedDate;
  final DateTime? suggestedEndDate;
}

class StudiosListPage extends StatelessWidget {
  const StudiosListPage({super.key, this.rehearsalContext});

  /// Optional context when navigating from a rehearsal - booking will be associated
  final RehearsalBookingContext? rehearsalContext;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StudiosCubit(
        repository: locate<StudiosRepository>(),
        imageService: locate<StudioImageService>(),
      )..loadAllStudios(refresh: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              rehearsalContext != null
                  ? 'Reservar Sala para Ensayo'
                  : 'Rehearsal Rooms',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: BlocBuilder<StudiosCubit, StudiosState>(
              builder: (context, state) {
                if (state.status == StudiosStatus.loading &&
                    state.studios.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.studios.isEmpty) {
                  return const Center(child: Text('No studios available.'));
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        final loadMore = _buildLoadMore(context, state);

                        if (isWide) {
                          return Column(
                            children: [
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () => context
                                      .read<StudiosCubit>()
                                      .loadAllStudios(refresh: true),
                                  child: GridView.builder(
                                    padding: const EdgeInsets.all(24),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          mainAxisExtent:
                                              280, // Adjust height for StudioCard
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
                                onRefresh: () => context
                                    .read<StudiosCubit>()
                                    .loadAllStudios(refresh: true),
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

  Widget _buildLoadMore(BuildContext context, StudiosState state) {
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
        onPressed: () => context.read<StudiosCubit>().loadAllStudios(),
        icon: const Icon(Icons.expand_more),
        label: const Text('Cargar más estudios'),
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

class StudioRoomsPage extends StatelessWidget {
  const StudioRoomsPage({
    super.key,
    required this.studioId,
    this.rehearsalContext,
  });

  final String studioId;
  final RehearsalBookingContext? rehearsalContext;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StudiosCubit(
        repository: locate<StudiosRepository>(),
        imageService: locate<StudioImageService>(),
      )..selectStudio(studioId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              'Salas del estudio',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: BlocBuilder<StudiosCubit, StudiosState>(
              builder: (context, state) {
                if (state.status == StudiosStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final rooms = state.myRooms; // Reused field as per cubit note
                final studioName = (state.selectedStudio?.name ?? '').trim();
                final resolvedStudioName = studioName.isEmpty
                    ? 'Salas del estudio'
                    : studioName;
                if (rooms.isEmpty) {
                  return const Center(
                    child: Text('No rooms available in this studio.'),
                  );
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;

                        if (isWide) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent:
                                      320, // Adjust height for RoomCard
                                ),
                            itemCount: rooms.length,
                            itemBuilder: (context, index) {
                              final room = rooms[index];
                              return RoomCard(
                                room: room,
                                studioName: resolvedStudioName,
                                onTap: () =>
                                    _navigateToRoomDetail(context, room),
                              );
                            },
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: RoomCard(
                                room: room,
                                studioName: resolvedStudioName,
                                onTap: () =>
                                    _navigateToRoomDetail(context, room),
                              ),
                            );
                          },
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

  void _navigateToRoomDetail(BuildContext context, RoomEntity room) {
    context.push(
      AppRoutes.studiosRoomDetailPath(studioId: studioId, roomId: room.id),
      extra: rehearsalContext,
    );
  }
}
