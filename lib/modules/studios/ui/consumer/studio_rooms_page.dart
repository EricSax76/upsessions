import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../cubits/studios_list_cubit.dart';
import '../../cubits/studios_list_state.dart';
import '../../cubits/studios_status.dart';
import '../../models/room_entity.dart';
import '../../repositories/studios_repository.dart';
import 'rehearsal_booking_context.dart';
import 'widgets/room_card.dart';

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
    final loc = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) =>
          StudiosListCubit(repository: locate<StudiosRepository>())
            ..selectStudio(studioId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Text(
              loc.studioRoomsTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: BlocBuilder<StudiosListCubit, StudiosListState>(
              builder: (context, state) {
                if (state.status == StudiosStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rooms = state.selectedStudioRooms;
                final studioName = (state.selectedStudio?.name ?? '').trim();
                final resolvedStudioName = studioName.isEmpty
                    ? loc.studioRoomsTitle
                    : studioName;

                if (rooms.isEmpty) {
                  return Center(child: Text(loc.studioRoomsEmpty));
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
                                  mainAxisExtent: 320,
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
