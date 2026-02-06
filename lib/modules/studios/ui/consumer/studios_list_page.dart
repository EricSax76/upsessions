import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
import 'room_detail_page.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import 'widgets/room_card.dart';
import 'widgets/studio_card.dart';

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
      create: (context) => StudiosCubit()..loadAllStudios(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(rehearsalContext != null
              ? 'Reservar Sala para Ensayo'
              : 'Rehearsal Rooms'),
        ),
        body: BlocBuilder<StudiosCubit, StudiosState>(
          builder: (context, state) {
            if (state.status == StudiosStatus.loading) {
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
                    
                    if (isWide) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 280, // Adjust height for StudioCard
                        ),
                        itemCount: state.studios.length,
                        itemBuilder: (context, index) {
                          final studio = state.studios[index];
                          return StudioCard(
                            studio: studio,
                            onTap: () => _navigateToRooms(context, studio),
                          );
                        },
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.studios.length,
                      itemBuilder: (context, index) {
                        final studio = state.studios[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: StudioCard(
                            studio: studio,
                            onTap: () => _navigateToRooms(context, studio),
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
    );
  }

  void _navigateToRooms(BuildContext context, dynamic studio) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserShellPage(
          child: StudioRoomsPage(
            studioId: studio.id,
            studioName: studio.name,
            rehearsalContext: rehearsalContext,
          ),
        ),
      ),
    );
  }
}

class StudioRoomsPage extends StatelessWidget {
  const StudioRoomsPage({
    super.key,
    required this.studioId,
    required this.studioName,
    this.rehearsalContext,
  });

  final String studioId;
  final String studioName;
  final RehearsalBookingContext? rehearsalContext;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StudiosCubit()..selectStudio(studioId),
      child: Scaffold(
        appBar: AppBar(title: Text(studioName)),
        body: BlocBuilder<StudiosCubit, StudiosState>(
          builder: (context, state) {
             if (state.status == StudiosStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final rooms = state.myRooms; // Reused field as per cubit note
             if (rooms.isEmpty) {
               return const Center(child: Text('No rooms available in this studio.'));
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
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 320, // Adjust height for RoomCard
                        ),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          return RoomCard(
                            room: room,
                            studioName: studioName,
                            onTap: () => _navigateToRoomDetail(context, room),
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
                            studioName: studioName,
                            onTap: () => _navigateToRoomDetail(context, room),
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
    );
  }
  
  void _navigateToRoomDetail(BuildContext context, dynamic room) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<StudiosCubit>(),
          child: UserShellPage( // Also wrap detail page to keep sidebar
            child: RoomDetailPage(
              room: room,
              studioName: studioName,
              rehearsalContext: rehearsalContext,
            ),
          ),
        ),
      ),
    );
  }
}
