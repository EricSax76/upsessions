import 'package:flutter/material.dart';

import '../features/events/models/event_entity.dart';
import '../features/events/repositories/events_repository.dart';
import '../features/events/ui/pages/event_detail_page.dart';
import '../modules/messaging/models/chat_thread.dart';
import '../modules/messaging/repositories/chat_repository.dart';
import '../modules/messaging/ui/pages/chat_thread_detail_page.dart';
import '../modules/announcements/models/announcement_entity.dart';
import '../modules/announcements/repositories/announcements_repository.dart';
import '../modules/announcements/ui/pages/announcement_detail_page.dart';
import '../modules/auth/repositories/auth_repository.dart';
import '../modules/musicians/models/musician_entity.dart';
import '../modules/musicians/repositories/musicians_repository.dart';
import '../modules/musicians/ui/pages/musician_detail_page.dart';
import '../modules/studios/models/room_entity.dart';
import '../modules/studios/repositories/studios_repository.dart';
import '../modules/studios/ui/consumer/room_detail_page.dart';
import '../modules/studios/ui/consumer/studios_list_page.dart';
import '../modules/studios/ui/provider/edit_room_page.dart';
import 'app_router_shell.dart';

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({super.key, required this.name, this.message});

  final String name;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ruta no encontrada')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('La ruta "$name" no existe.'),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MusicianDetailLoader extends StatelessWidget {
  const MusicianDetailLoader({
    super.key,
    required this.musicianId,
    required this.location,
    required this.musiciansRepository,
  });

  final String musicianId;
  final String location;
  final MusiciansRepository musiciansRepository;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MusicianEntity?>(
      future: musiciansRepository.findById(musicianId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return buildUserShell(
            context,
            const Center(child: CircularProgressIndicator()),
          );
        }

        final musician = snapshot.data;
        if (snapshot.hasError || musician == null) {
          return UnknownRouteScreen(
            name: location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro el musico solicitado.',
          );
        }

        return buildUserShell(context, MusicianDetailPage(musician: musician));
      },
    );
  }
}

class AnnouncementDetailLoader extends StatelessWidget {
  const AnnouncementDetailLoader({
    super.key,
    required this.announcementId,
    required this.location,
    required this.announcementsRepository,
  });

  final String announcementId;
  final String location;
  final AnnouncementsRepository announcementsRepository;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AnnouncementEntity>(
      future: announcementsRepository.findById(announcementId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return buildUserShell(
            context,
            const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return UnknownRouteScreen(
            name: location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro el anuncio solicitado.',
          );
        }

        return buildUserShell(
          context,
          AnnouncementDetailPage(announcement: snapshot.data!),
        );
      },
    );
  }
}

class EventDetailLoader extends StatelessWidget {
  const EventDetailLoader({
    super.key,
    required this.eventId,
    required this.location,
    required this.eventsRepository,
  });

  final String eventId;
  final String location;
  final EventsRepository eventsRepository;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EventEntity?>(
      future: eventsRepository.findById(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final event = snapshot.data;
        if (snapshot.hasError || event == null) {
          return UnknownRouteScreen(
            name: location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro el evento solicitado.',
          );
        }

        return EventDetailPage(
          event: event,
          eventsRepository: eventsRepository,
        );
      },
    );
  }
}

class ChatThreadDetailLoader extends StatelessWidget {
  const ChatThreadDetailLoader({
    super.key,
    required this.threadId,
    required this.location,
    required this.chatRepository,
    required this.authRepository,
    this.initialThread,
  });

  final ChatRepository chatRepository;
  final AuthRepository authRepository;

  final String threadId;
  final String location;
  final ChatThread? initialThread;

  Future<ChatThread?> _loadThread() async {
    final seedThread = initialThread;
    if (seedThread != null && seedThread.id == threadId) {
      return seedThread;
    }
    return chatRepository.fetchThread(threadId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChatThread?>(
      future: _loadThread(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final thread = snapshot.data;
        if (snapshot.hasError || thread == null) {
          return UnknownRouteScreen(
            name: location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro el chat solicitado.',
          );
        }

        final currentUserId = authRepository.currentUser?.id ?? '';
        return ChatThreadDetailPage(
          thread: thread,
          threadTitle: thread.titleFor(currentUserId),
          chatRepository: chatRepository,
        );
      },
    );
  }
}

class StudioRoomDetailLoader extends StatelessWidget {
  const StudioRoomDetailLoader({
    super.key,
    required this.studioId,
    required this.roomId,
    required this.location,
    required this.studiosRepository,
    this.rehearsalContext,
  });

  final String studioId;
  final String roomId;
  final String location;
  final StudiosRepository studiosRepository;
  final RehearsalBookingContext? rehearsalContext;

  Future<_StudioRoomDetailData?> _loadRoomDetail() async {
    final studio = await studiosRepository.getStudioById(studioId);
    final rooms = await studiosRepository.getRoomsByStudio(studioId);

    RoomEntity? room;
    for (final candidate in rooms) {
      if (candidate.id == roomId) {
        room = candidate;
        break;
      }
    }

    if (room == null) {
      return null;
    }

    final resolvedStudioName = (studio?.name ?? '').trim();
    return _StudioRoomDetailData(
      room: room,
      studioName: resolvedStudioName.isEmpty ? 'Studio' : resolvedStudioName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StudioRoomDetailData?>(
      future: _loadRoomDetail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        if (snapshot.hasError || data == null) {
          return UnknownRouteScreen(
            name: location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro la sala solicitada.',
          );
        }

        return RoomDetailPage(
          room: data.room,
          studioName: data.studioName,
          rehearsalContext: rehearsalContext,
        );
      },
    );
  }
}

class StudioRoomEditorLoader extends StatelessWidget {
  const StudioRoomEditorLoader({
    super.key,
    required this.studioId,
    required this.roomId,
    required this.location,
    required this.studiosRepository,
  });

  final String studioId;
  final String roomId;
  final String location;
  final StudiosRepository studiosRepository;

  Future<RoomEntity?> _loadRoom() async {
    final rooms = await studiosRepository.getRoomsByStudio(studioId);
    for (final candidate in rooms) {
      if (candidate.id == roomId) {
        return candidate;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RoomEntity?>(
      future: _loadRoom(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final room = snapshot.data;
        if (snapshot.hasError || room == null) {
          return UnknownRouteScreen(
            name: location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro la sala solicitada.',
          );
        }

        return EditRoomPage(studioId: studioId, room: room);
      },
    );
  }
}

class _StudioRoomDetailData {
  const _StudioRoomDetailData({required this.room, required this.studioName});

  final RoomEntity room;
  final String studioName;
}
