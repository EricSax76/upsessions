import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/locator/locator.dart';
import '../modules/events/models/event_entity.dart';
import '../modules/events/ui/pages/event_detail_page.dart';
import '../modules/events/repositories/events_repository.dart';
import '../features/messaging/models/chat_thread.dart';
import '../features/messaging/ui/pages/messages_page.dart';
import '../modules/announcements/models/announcement_entity.dart';
import '../modules/announcements/repositories/announcements_repository.dart';
import '../modules/announcements/ui/pages/announcement_detail_page.dart';
import '../modules/auth/repositories/auth_repository.dart';
import '../modules/auth/repositories/profile_repository.dart';

import '../modules/groups/ui/pages/group_page.dart';
import '../modules/musicians/models/musician_entity.dart';
import '../modules/musicians/repositories/musicians_repository.dart';
import '../modules/musicians/ui/pages/musician_detail_page.dart';
import '../modules/rehearsals/ui/pages/group_rehearsals_page.dart';
import '../modules/groups/ui/pages/invite_accept_page.dart';
import '../modules/rehearsals/ui/pages/rehearsal_detail_page.dart';
import '../modules/studios/cubits/my_studio_cubit.dart';
import '../modules/studios/ui/consumer/studio_rooms_page.dart';
import '../modules/studios/ui/consumer/studios_list_page.dart';
import '../modules/studios/ui/provider/edit_room_page.dart';
import '../modules/studios/ui/provider/studio_profile_page.dart';
import '../modules/studios/repositories/studios_repository.dart';
import '../modules/groups/repositories/groups_repository.dart';
import '../features/messaging/repositories/chat_repository.dart';
import '../modules/notifications/repositories/invite_notifications_repository.dart';
import '../modules/contacts/cubits/liked_musicians_cubit.dart';
import '../modules/studios/ui/widgets/studio_shell_page.dart';
import 'app_router_loaders.dart';
import 'app_router_parsers.dart';

Widget buildMusicianDetailRoute(BuildContext context, GoRouterState state) {
  final musician = state.extra;
  if (musician is MusicianEntity) {
    return MusicianDetailPage(musician: musician);
  }

  final musicianId = musicianIdFromState(state);
  if (musicianId != null && musicianId.isNotEmpty) {
    return MusicianDetailLoader(
      musicianId: musicianId,
      location: state.uri.toString(),
      musiciansRepository: context.read<MusiciansRepository>(),
    );
  }

  return UnknownRouteScreen(
    name: state.uri.toString(),
    message: 'Missing MusicianEntity for ${state.uri}',
  );
}

Widget buildAnnouncementDetailRoute(BuildContext context, GoRouterState state) {
  final announcement = state.extra;
  if (announcement is AnnouncementEntity) {
    return AnnouncementDetailPage(announcement: announcement);
  }

  final announcementId = announcementIdFromState(state);
  if (announcementId != null && announcementId.isNotEmpty) {
    return AnnouncementDetailLoader(
      announcementId: announcementId,
      location: state.uri.toString(),
      announcementsRepository: context.read<AnnouncementsRepository>(),
    );
  }

  return UnknownRouteScreen(
    name: state.uri.toString(),
    message: 'Missing AnnouncementEntity for ${state.uri}',
  );
}

Widget buildEventDetailRoute(BuildContext context, GoRouterState state) {
  final extra = state.extra;
  if (extra is EventEntity) {
    return EventDetailPage(
      event: extra,
      eventsRepository: context.read<EventsRepository>(),
    );
  }

  final eventId = eventIdFromState(state);
  if (eventId != null && eventId.isNotEmpty) {
    return EventDetailLoader(
      eventId: eventId,
      location: state.uri.toString(),
      eventsRepository: context.read<EventsRepository>(),
    );
  }

  return UnknownRouteScreen(
    name: state.uri.toString(),
    message: 'Missing EventEntity for ${state.uri}',
  );
}

Widget buildGroupRoute(BuildContext context, GoRouterState state) {
  final groupId = state.pathParameters['groupId'];
  if (groupId == null) return const UnknownRouteScreen(name: 'Group');
  return GroupPage(
    groupId: groupId,
    rehearsalsTab: GroupRehearsalsView(
      groupId: groupId,
      showHeader: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    ),
  );
}

Widget buildGroupRehearsalsRoute(BuildContext context, GoRouterState state) {
  final groupId = state.pathParameters['groupId'];
  if (groupId == null) {
    return const UnknownRouteScreen(name: 'Group Rehearsals');
  }
  return GroupRehearsalsPage(groupId: groupId);
}

Widget buildRehearsalDetailRoute(BuildContext context, GoRouterState state) {
  final groupId = state.pathParameters['groupId'];
  final rehearsalId = state.pathParameters['rehearsalId'];
  if (groupId == null || rehearsalId == null) {
    return const UnknownRouteScreen(name: 'Rehearsal Detail');
  }
  return RehearsalDetailPage(groupId: groupId, rehearsalId: rehearsalId);
}

Widget buildStudiosListRoute(BuildContext context, GoRouterState state) {
  final rehearsalContext = rehearsalContextFromState(state);
  return StudiosListPage(rehearsalContext: rehearsalContext);
}

Widget buildStudiosRoomsRoute(BuildContext context, GoRouterState state) {
  final studioId = state.pathParameters['studioId']?.trim();
  if (studioId == null || studioId.isEmpty) {
    return UnknownRouteScreen(
      name: state.uri.toString(),
      message: 'Missing studioId for ${state.uri}',
    );
  }

  final rehearsalContext = rehearsalContextFromState(state);
  return StudioRoomsPage(
    studioId: studioId,
    rehearsalContext: rehearsalContext,
  );
}

Widget buildStudiosRoomDetailRoute(BuildContext context, GoRouterState state) {
  final studioId = state.pathParameters['studioId']?.trim();
  final roomId = state.pathParameters['roomId']?.trim();
  if (studioId == null ||
      studioId.isEmpty ||
      roomId == null ||
      roomId.isEmpty) {
    return UnknownRouteScreen(
      name: state.uri.toString(),
      message: 'Missing studioId/roomId for ${state.uri}',
    );
  }

  final rehearsalContext = rehearsalContextFromState(state);
  return StudioRoomDetailLoader(
    studioId: studioId,
    roomId: roomId,
    rehearsalContext: rehearsalContext,
    location: state.uri.toString(),
    studiosRepository: context.read<StudiosRepository>(),
  );
}

Widget buildStudiosRoomCreateRoute(BuildContext context, GoRouterState state) {
  final studioId = state.pathParameters['studioId']?.trim();
  if (studioId == null || studioId.isEmpty) {
    return UnknownRouteScreen(
      name: state.uri.toString(),
      message: 'Missing studioId for ${state.uri}',
    );
  }

  return BlocProvider(
    create: (context) => MyStudioCubit(repository: locate<StudiosRepository>()),
    child: StudioShellPage(child: EditRoomPage(studioId: studioId)),
  );
}

Widget buildStudiosRoomEditRoute(BuildContext context, GoRouterState state) {
  final studioId = state.pathParameters['studioId']?.trim();
  final roomId = state.pathParameters['roomId']?.trim();
  if (studioId == null ||
      studioId.isEmpty ||
      roomId == null ||
      roomId.isEmpty) {
    return UnknownRouteScreen(
      name: state.uri.toString(),
      message: 'Missing studioId/roomId for ${state.uri}',
    );
  }

  return BlocProvider(
    create: (context) => MyStudioCubit(repository: locate<StudiosRepository>()),
    child: StudioShellPage(
      child: StudioRoomEditorLoader(
        studioId: studioId,
        roomId: roomId,
        location: state.uri.toString(),
        studiosRepository: context.read<StudiosRepository>(),
      ),
    ),
  );
}

Widget buildMessagesRoute(BuildContext context, GoRouterState state) {
  final threadId = threadIdFromState(state);
  return MessagesPage(
    initialThreadId: threadId,
    groupsRepository: context.read<GroupsRepository>(),
    chatRepository: context.read<ChatRepository>(),
    inviteNotificationsRepository: context
        .read<InviteNotificationsRepository>(),
    likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
    authRepository: context.read<AuthRepository>(),
    profileRepository: context.read<ProfileRepository>(),
  );
}

Widget buildChatThreadDetailRoute(BuildContext context, GoRouterState state) {
  final threadId = threadIdFromState(state);
  if (threadId == null || threadId.isEmpty) {
    return UnknownRouteScreen(
      name: state.uri.toString(),
      message: 'Missing threadId for ${state.uri}',
    );
  }

  final extra = state.extra;
  final initialThread = extra is ChatThread ? extra : null;
  return ChatThreadDetailLoader(
    threadId: threadId,
    initialThread: initialThread,
    location: state.uri.toString(),
    chatRepository: context.read<ChatRepository>(),
    authRepository: context.read<AuthRepository>(),
  );
}

Widget buildInviteAcceptRoute(BuildContext context, GoRouterState state) {
  final groupId = inviteGroupIdFromState(state) ?? '';
  final inviteId = inviteIdFromState(state) ?? '';
  return InviteAcceptPage(
    groupId: groupId,
    inviteId: inviteId,
    groupsRepository: context.read<GroupsRepository>(),
    inviteNotificationsRepository: context
        .read<InviteNotificationsRepository>(),
    authRepository: context.read<AuthRepository>(),
  );
}

Widget buildStudiosProfileRoute(BuildContext context, GoRouterState state) {
  final extra = state.extra;
  if (extra is MyStudioCubit) {
    return BlocProvider.value(
      value: extra,
      child: const StudioShellPage(child: StudioProfilePage()),
    );
  }

  final authRepo = locate<AuthRepository>();
  final userId = authRepo.currentUser?.id;
  return BlocProvider(
    create: (_) {
      final cubit = MyStudioCubit(repository: locate<StudiosRepository>());
      if (userId != null && userId.isNotEmpty) {
        cubit.loadMyStudio(userId);
      }
      return cubit;
    },
    child: const StudioShellPage(child: StudioProfilePage()),
  );
}
