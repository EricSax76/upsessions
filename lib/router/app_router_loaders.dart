import 'package:flutter/material.dart';

import '../modules/events/models/event_entity.dart';
import '../modules/events/repositories/events_repository.dart';
import '../modules/events/ui/pages/event_detail_page.dart';
import '../features/messaging/models/chat_thread.dart';
import '../features/messaging/repositories/chat_repository.dart';
import '../features/messaging/ui/pages/chat_thread_detail_page.dart';
import '../modules/announcements/models/announcement_entity.dart';
import '../modules/announcements/repositories/announcements_repository.dart';
import '../modules/announcements/ui/pages/announcement_detail_page.dart';
import '../modules/auth/repositories/auth_repository.dart';
import '../modules/musicians/models/musician_entity.dart';
import '../modules/musicians/repositories/musicians_repository.dart';
import '../modules/musicians/ui/pages/musician_detail_page.dart';
import '../modules/studios/models/room_entity.dart';
import '../modules/studios/models/studio_entity.dart';
import '../modules/studios/repositories/studios_repository.dart';
import '../modules/studios/ui/consumer/room_detail_page.dart';
import '../modules/studios/ui/consumer/studios_list_page.dart';
import '../modules/studios/ui/provider/edit_room_page.dart';

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

class MusicianDetailLoader extends StatefulWidget {
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
  State<MusicianDetailLoader> createState() => _MusicianDetailLoaderState();
}

class _MusicianDetailLoaderState extends State<MusicianDetailLoader> {
  late final Future<MusicianEntity?> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.musiciansRepository.findById(widget.musicianId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MusicianEntity?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final musician = snapshot.data;
        if (snapshot.hasError || musician == null) {
          return UnknownRouteScreen(
            name: widget.location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro el musico solicitado.',
          );
        }

        return MusicianDetailPage(musician: musician);
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
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return UnknownRouteScreen(
            name: location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro el anuncio solicitado.',
          );
        }

        return AnnouncementDetailPage(announcement: snapshot.data!);
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

class ChatThreadDetailLoader extends StatefulWidget {
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

  @override
  State<ChatThreadDetailLoader> createState() => _ChatThreadDetailLoaderState();
}

class _ChatThreadDetailLoaderState extends State<ChatThreadDetailLoader> {
  late final Future<ChatThread?> _future;

  @override
  void initState() {
    super.initState();
    final seedThread = widget.initialThread;
    if (seedThread != null && seedThread.id == widget.threadId) {
      _future = Future.value(seedThread);
    } else {
      _future = widget.chatRepository.fetchThread(widget.threadId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChatThread?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final thread = snapshot.data;
        if (snapshot.hasError || thread == null) {
          return UnknownRouteScreen(
            name: widget.location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro el chat solicitado.',
          );
        }

        final currentUserId = widget.authRepository.currentUser?.id ?? '';
        return ChatThreadDetailPage(
          thread: thread,
          threadTitle: thread.titleFor(currentUserId),
          chatRepository: widget.chatRepository,
        );
      },
    );
  }
}

class StudioRoomDetailLoader extends StatefulWidget {
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

  @override
  State<StudioRoomDetailLoader> createState() => _StudioRoomDetailLoaderState();
}

class _StudioRoomDetailLoaderState extends State<StudioRoomDetailLoader> {
  late final Future<_StudioRoomDetailData?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadRoomDetail();
  }

  Future<_StudioRoomDetailData?> _loadRoomDetail() async {
    final results = await Future.wait([
      widget.studiosRepository.getStudioById(widget.studioId),
      widget.studiosRepository.getRoomById(
        studioId: widget.studioId,
        roomId: widget.roomId,
      ),
    ]);

    final studio = results[0] as StudioEntity?;
    final room = results[1] as RoomEntity?;

    if (room == null) return null;

    final resolvedStudioName = (studio?.name ?? '').trim();
    return _StudioRoomDetailData(
      room: room,
      studioName: resolvedStudioName.isEmpty ? 'Studio' : resolvedStudioName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StudioRoomDetailData?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        if (snapshot.hasError || data == null) {
          return UnknownRouteScreen(
            name: widget.location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro la sala solicitada.',
          );
        }

        return RoomDetailPage(
          room: data.room,
          studioName: data.studioName,
          rehearsalContext: widget.rehearsalContext,
        );
      },
    );
  }
}

class StudioRoomEditorLoader extends StatefulWidget {
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

  @override
  State<StudioRoomEditorLoader> createState() => _StudioRoomEditorLoaderState();
}

class _StudioRoomEditorLoaderState extends State<StudioRoomEditorLoader> {
  late final Future<RoomEntity?> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.studiosRepository.getRoomById(
      studioId: widget.studioId,
      roomId: widget.roomId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RoomEntity?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final room = snapshot.data;
        if (snapshot.hasError || room == null) {
          return UnknownRouteScreen(
            name: widget.location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro la sala solicitada.',
          );
        }

        return EditRoomPage(studioId: widget.studioId, room: room);
      },
    );
  }
}

class _StudioRoomDetailData {
  const _StudioRoomDetailData({required this.room, required this.studioName});

  final RoomEntity room;
  final String studioName;
}
