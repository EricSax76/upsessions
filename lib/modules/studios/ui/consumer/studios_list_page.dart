import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
import 'room_detail_page.dart';

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
            return ListView.builder(
              itemCount: state.studios.length,
              itemBuilder: (context, index) {
                final studio = state.studios[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text(studio.name),
                    subtitle: Text(studio.address),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => StudioRoomsPage(
                                  studioId: studio.id,
                                  studioName: studio.name,
                                  rehearsalContext: rehearsalContext,
                                ),
                              ),
                            );
                          },
                          child: const Text('View Rooms'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
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
            return ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return ListTile(
                  title: Text(room.name),
                  subtitle: Text('${room.capacity} ppl • ${room.pricePerHour}€/hr'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<StudiosCubit>(),
                          child: RoomDetailPage(
                            room: room,
                            studioName: studioName,
                            rehearsalContext: rehearsalContext,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
