import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../modules/announcements/models/announcement_entity.dart';
import '../modules/announcements/repositories/announcements_repository.dart';
import '../modules/announcements/ui/pages/announcement_detail_page.dart';
import '../modules/announcements/ui/pages/announcement_form_page.dart';
import '../modules/announcements/ui/pages/announcements_hub_page.dart';
import '../features/media/ui/pages/media_gallery_page.dart';
import '../features/calendar/ui/pages/calendar_page.dart';
import '../features/events/repositories/events_repository.dart';
import '../features/events/models/event_entity.dart';
import '../features/events/ui/pages/create_event_page.dart';
import '../features/events/ui/pages/event_detail_page.dart';
import '../features/events/ui/pages/events_page.dart';
import '../features/messaging/models/chat_thread.dart';
import '../features/messaging/repositories/chat_repository.dart';
import '../features/messaging/ui/pages/chat_thread_detail_page.dart';
import '../features/messaging/ui/pages/messages_page.dart';
import '../features/onboarding/ui/pages/app_welcome_page.dart';
import '../features/onboarding/ui/pages/musician_onboarding_page.dart';
import '../features/onboarding/ui/pages/onboarding_story_pages.dart';
import '../features/notifications/ui/pages/notifications_page.dart';
import '../features/settings/ui/pages/settings_page.dart';
import '../features/settings/ui/pages/help_page.dart';
import '../home/splash/presentation/splash_page.dart';
import '../modules/groups/ui/pages/group_page.dart';
import '../modules/groups/ui/pages/groups_page.dart';
import '../modules/rehearsals/ui/pages/group_rehearsals_page.dart';
import '../modules/rehearsals/ui/pages/invite_accept_page.dart';
import '../modules/rehearsals/ui/pages/rehearsal_detail_page.dart';
import '../home/ui/pages/user_home_page.dart';
import '../modules/auth/ui/pages/forgot_password_page.dart';
import '../modules/auth/ui/pages/login_page.dart';
import '../modules/auth/ui/pages/register_page.dart';
import '../modules/auth/repositories/auth_repository.dart';
import '../modules/musicians/models/musician_entity.dart';
import '../modules/musicians/repositories/musicians_repository.dart';
import '../home/ui/pages/user_shell_page.dart';
import '../modules/musicians/ui/pages/musician_detail_page.dart';
import '../modules/musicians/ui/pages/musicians_hub_page.dart';
import '../modules/profile/ui/pages/account_page.dart';
import '../modules/profile/ui/pages/profile_edit_page.dart';
import '../modules/profile/ui/pages/profile_overview_page.dart';
import 'package:upsessions/core/locator/locator.dart';
import '../modules/matching/ui/pages/matching_page.dart';
import '../features/contacts/ui/pages/contacts_page.dart';
import '../modules/studios/ui/consumer/studios_list_page.dart';
import '../modules/studios/ui/consumer/room_detail_page.dart';
import '../modules/studios/cubits/studios_cubit.dart';
import '../modules/studios/models/room_entity.dart';
import '../modules/studios/repositories/studios_repository.dart';
import '../modules/studios/ui/provider/create_studio_page.dart';
import '../modules/studios/ui/provider/studio_dashboard_page.dart';
import '../modules/studios/ui/provider/edit_room_page.dart';
import '../modules/studios/ui/auth/studio_login_page.dart';
import '../modules/studios/ui/auth/studio_register_page.dart';
import '../modules/studios/ui/provider/studio_profile_page.dart';

import '../modules/studios/ui/consumer/musician_bookings_page.dart';

class AppRouter {
  AppRouter() {
    router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, state) => AppWelcomePage(
            onContinue: () => context.go(AppRoutes.onboardingStoryOne),
          ),
        ),
        GoRoute(
          path: AppRoutes.onboardingStoryOne,
          builder: (context, state) => CollaborateOnboardingPage(
            onContinue: () => context.go(AppRoutes.onboardingStoryTwo),
            onSkip: () => context.go(AppRoutes.login),
          ),
        ),
        GoRoute(
          path: AppRoutes.onboardingStoryTwo,
          builder: (context, state) => ShowcaseOnboardingPage(
            onContinue: () => context.go(AppRoutes.onboardingStoryThree),
            onSkip: () => context.go(AppRoutes.login),
          ),
        ),
        GoRoute(
          path: AppRoutes.onboardingStoryThree,
          builder: (context, state) => BookOnboardingPage(
            onContinue: () => context.go(AppRoutes.login),
            onSkip: () => context.go(AppRoutes.login),
          ),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: AppRoutes.musicianOnboarding,
          builder: (context, state) => const MusicianOnboardingPage(),
        ),
        GoRoute(
          path: AppRoutes.userHome,
          builder: (context, state) => const UserHomePage(),
        ),
        GoRoute(
          path: AppRoutes.musicians,
          builder: (context, state) => const MusiciansHubPage(),
        ),
        GoRoute(path: AppRoutes.musicianDetail, builder: _buildMusicianDetail),
        GoRoute(
          path: AppRoutes.musicianDetailRoute,
          builder: _buildMusicianDetail,
        ),
        GoRoute(
          path: AppRoutes.musicianDetailLegacyRoute,
          builder: _buildMusicianDetail,
        ),
        GoRoute(
          path: AppRoutes.announcements,
          builder: (context, state) => const AnnouncementsHubPage(),
        ),
        GoRoute(
          path: AppRoutes.announcementDetail,
          builder: _buildAnnouncementDetail,
        ),
        GoRoute(
          path: AppRoutes.announcementDetailRoute,
          builder: _buildAnnouncementDetail,
        ),
        GoRoute(
          path: AppRoutes.announcementForm,
          builder: (context, state) =>
              AnnouncementFormPage(repository: locate()),
        ),
        GoRoute(
          path: AppRoutes.media,
          builder: (context, state) => const MediaGalleryPage(),
        ),
        GoRoute(
          path: AppRoutes.messages,
          builder: _buildMessages,
        ),
        GoRoute(
          path: AppRoutes.messagesThreadRoute,
          builder: _buildMessages,
        ),
        GoRoute(
          path: AppRoutes.messagesThreadDetailRoute,
          builder: _buildChatThreadDetail,
        ),
        GoRoute(
          path: AppRoutes.contacts,
          builder: (context, state) => ContactsPage(controller: locate()),
        ),
        GoRoute(
          path: AppRoutes.calendar,
          builder: (context, state) => const CalendarPage(),
        ),
        GoRoute(
          path: AppRoutes.events,
          builder: (context, state) => const EventsPage(),
        ),
        GoRoute(
          path: AppRoutes.createEvent,
          builder: (context, state) =>
              const UserShellPage(child: CreateEventPage()),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: AppRoutes.rehearsals,
          builder: (context, state) => const GroupsPage(),
        ),
        GoRoute(
          path: AppRoutes.groupRoute,
          builder: (context, state) {
            final groupId = state.pathParameters['groupId'] ?? '';
            return GroupPage(groupId: groupId);
          },
        ),
        GoRoute(
          path: AppRoutes.groupRehearsalsRoute,
          builder: (context, state) {
            final groupId = state.pathParameters['groupId'] ?? '';
            return GroupRehearsalsPage(groupId: groupId);
          },
        ),
        GoRoute(
          path: AppRoutes.rehearsalDetailRoute,
          builder: (context, state) {
            final groupId = state.pathParameters['groupId'] ?? '';
            final rehearsalId = state.pathParameters['rehearsalId'] ?? '';
            return RehearsalDetailPage(
              groupId: groupId,
              rehearsalId: rehearsalId,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.invite,
          builder: _buildInviteAccept,
        ),
        GoRoute(
          path: AppRoutes.inviteRoute,
          builder: _buildInviteAccept,
        ),
        GoRoute(path: AppRoutes.eventDetail, builder: _buildEventDetail),
        GoRoute(path: AppRoutes.eventDetailRoute, builder: _buildEventDetail),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileOverviewPage(),
        ),
        GoRoute(
          path: AppRoutes.profileEdit,
          builder: (context, state) => const ProfileEditPage(),
        ),
        GoRoute(
          path: AppRoutes.account,
          builder: (context, state) => const AccountPage(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: AppRoutes.help,
          builder: (context, state) => const HelpPage(),
        ),
        GoRoute(
          path: AppRoutes.studios,
          builder: _buildStudiosList,
        ),
        GoRoute(
          path: AppRoutes.studiosRoomsRoute,
          builder: _buildStudiosRooms,
        ),
        GoRoute(
          path: AppRoutes.studiosRoomCreateRoute,
          builder: _buildStudiosRoomCreate,
        ),
        GoRoute(
          path: AppRoutes.studiosRoomEditRoute,
          builder: _buildStudiosRoomEdit,
        ),
        GoRoute(
          path: AppRoutes.studiosRoomDetailRoute,
          builder: _buildStudiosRoomDetail,
        ),
        GoRoute(
          path: AppRoutes.studiosLogin,
          builder: (context, state) => const StudioLoginPage(),
        ),
        GoRoute(
          path: AppRoutes.studiosRegister,
          builder: (context, state) => const StudioRegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.studiosCreate,
          builder: (context, state) => const CreateStudioPage(),
        ),
        GoRoute(
          path: AppRoutes.studiosDashboard,
          builder: (context, state) => const StudioDashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.studiosProfile,
          builder: (context, state) {
            final extra = state.extra;
            if (extra is StudiosCubit) {
              return BlocProvider.value(
                value: extra,
                child: const StudioProfilePage(),
              );
            }

            final authRepo = locate<AuthRepository>();
            final userId = authRepo.currentUser?.id;
            return BlocProvider(
              create: (_) {
                final cubit = StudiosCubit();
                if (userId != null && userId.isNotEmpty) {
                  cubit.loadMyStudio(userId);
                }
                return cubit;
              },
              child: const StudioProfilePage(),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.myBookings,
          builder: (context, state) =>
              UserShellPage(child: const MusicianBookingsPage()),
        ),
        GoRoute(
          path: AppRoutes.matching,
          builder: (context, state) =>
              const UserShellPage(child: MatchingPage()),
        ),
      ],
      errorBuilder: (context, state) => _UnknownRouteScreen(
        name: state.uri.toString(),
        message: state.error?.toString(),
      ),
    );
  }

  late final GoRouter router;
}

Widget _buildMusicianDetail(BuildContext context, GoRouterState state) {
  final musician = state.extra;
  if (musician is MusicianEntity) {
    return UserShellPage(child: MusicianDetailPage(musician: musician));
  }
  final musicianId = _musicianIdFromState(state);
  if (musicianId != null && musicianId.isNotEmpty) {
    return _MusicianDetailLoader(
      musicianId: musicianId,
      location: state.uri.toString(),
    );
  }
  return _UnknownRouteScreen(
    name: state.uri.toString(),
    message: 'Missing MusicianEntity for ${state.uri}',
  );
}

Widget _buildAnnouncementDetail(BuildContext context, GoRouterState state) {
  final announcement = state.extra;
  if (announcement is AnnouncementEntity) {
    return UserShellPage(
      child: AnnouncementDetailPage(announcement: announcement),
    );
  }
  final announcementId = _announcementIdFromState(state);
  if (announcementId != null && announcementId.isNotEmpty) {
    return _AnnouncementDetailLoader(
      announcementId: announcementId,
      location: state.uri.toString(),
    );
  }
  return _UnknownRouteScreen(
    name: state.uri.toString(),
    message: 'Missing AnnouncementEntity for ${state.uri}',
  );
}

Widget _buildEventDetail(BuildContext context, GoRouterState state) {
  final extra = state.extra;
  if (extra is EventEntity) {
    return UserShellPage(child: EventDetailPage(event: extra));
  }
  final eventId = _eventIdFromState(state);
  if (eventId != null && eventId.isNotEmpty) {
    return UserShellPage(
      child: _EventDetailLoader(eventId: eventId, location: state.uri.toString()),
    );
  }
  return _UnknownRouteScreen(
    name: state.uri.toString(),
    message: 'Missing EventEntity for ${state.uri}',
  );
}

Widget _buildStudiosList(BuildContext context, GoRouterState state) {
  final rehearsalContext = _rehearsalContextFromState(state);
  return UserShellPage(child: StudiosListPage(rehearsalContext: rehearsalContext));
}

Widget _buildStudiosRooms(BuildContext context, GoRouterState state) {
  final studioId = state.pathParameters['studioId']?.trim();
  if (studioId == null || studioId.isEmpty) {
    return _UnknownRouteScreen(
      name: state.uri.toString(),
      message: 'Missing studioId for ${state.uri}',
    );
  }
  final rehearsalContext = _rehearsalContextFromState(state);
  return UserShellPage(
    child: StudioRoomsPage(
      studioId: studioId,
      rehearsalContext: rehearsalContext,
    ),
  );
}

Widget _buildStudiosRoomDetail(BuildContext context, GoRouterState state) {
  final studioId = state.pathParameters['studioId']?.trim();
  final roomId = state.pathParameters['roomId']?.trim();
  if (studioId == null ||
      studioId.isEmpty ||
      roomId == null ||
      roomId.isEmpty) {
    return _UnknownRouteScreen(
      name: state.uri.toString(),
      message: 'Missing studioId/roomId for ${state.uri}',
    );
  }
  final rehearsalContext = _rehearsalContextFromState(state);
  return UserShellPage(
    child: _StudioRoomDetailLoader(
      studioId: studioId,
      roomId: roomId,
      rehearsalContext: rehearsalContext,
      location: state.uri.toString(),
    ),
  );
}

Widget _buildStudiosRoomCreate(BuildContext context, GoRouterState state) {
  final studioId = state.pathParameters['studioId']?.trim();
  if (studioId == null || studioId.isEmpty) {
    return _UnknownRouteScreen(
      name: state.uri.toString(),
      message: 'Missing studioId for ${state.uri}',
    );
  }
  return EditRoomPage(studioId: studioId);
}

Widget _buildStudiosRoomEdit(BuildContext context, GoRouterState state) {
  final studioId = state.pathParameters['studioId']?.trim();
  final roomId = state.pathParameters['roomId']?.trim();
  if (studioId == null ||
      studioId.isEmpty ||
      roomId == null ||
      roomId.isEmpty) {
    return _UnknownRouteScreen(
      name: state.uri.toString(),
      message: 'Missing studioId/roomId for ${state.uri}',
    );
  }
  return _StudioRoomEditorLoader(
    studioId: studioId,
    roomId: roomId,
    location: state.uri.toString(),
  );
}

Widget _buildMessages(BuildContext context, GoRouterState state) {
  final threadId = _threadIdFromState(state);
  if (threadId == null || threadId.isEmpty) {
    return const MessagesPage();
  }
  return MessagesPage(initialThreadId: threadId);
}

Widget _buildChatThreadDetail(BuildContext context, GoRouterState state) {
  final threadId = _threadIdFromState(state);
  if (threadId == null || threadId.isEmpty) {
    return _UnknownRouteScreen(
      name: state.uri.toString(),
      message: 'Missing threadId for ${state.uri}',
    );
  }
  final extra = state.extra;
  final initialThread = extra is ChatThread ? extra : null;
  return _ChatThreadDetailLoader(
    threadId: threadId,
    initialThread: initialThread,
    location: state.uri.toString(),
  );
}

Widget _buildInviteAccept(BuildContext context, GoRouterState state) {
  final groupId = _inviteGroupIdFromState(state) ?? '';
  final inviteId = _inviteIdFromState(state) ?? '';
  return InviteAcceptPage(groupId: groupId, inviteId: inviteId);
}

String? _musicianIdFromState(GoRouterState state) {
  final pathId = state.pathParameters['musicianId']?.trim();
  if (pathId != null && pathId.isNotEmpty) {
    return pathId;
  }
  final queryId = state.uri.queryParameters['musicianId']?.trim();
  if (queryId != null && queryId.isNotEmpty) {
    return queryId;
  }
  final extra = state.extra;
  if (extra is MusicianEntity && extra.id.trim().isNotEmpty) {
    return extra.id.trim();
  }
  return null;
}

String? _announcementIdFromState(GoRouterState state) {
  final pathId = state.pathParameters['announcementId']?.trim();
  if (pathId != null && pathId.isNotEmpty) {
    return pathId;
  }
  final queryId = state.uri.queryParameters['announcementId']?.trim();
  if (queryId != null && queryId.isNotEmpty) {
    return queryId;
  }
  final extra = state.extra;
  if (extra is AnnouncementEntity && extra.id.trim().isNotEmpty) {
    return extra.id.trim();
  }
  return null;
}

String? _eventIdFromState(GoRouterState state) {
  final pathId = state.pathParameters['eventId']?.trim();
  if (pathId != null && pathId.isNotEmpty) {
    return pathId;
  }
  final queryId = state.uri.queryParameters['eventId']?.trim();
  if (queryId != null && queryId.isNotEmpty) {
    return queryId;
  }
  final extra = state.extra;
  if (extra is EventEntity && extra.id.trim().isNotEmpty) {
    return extra.id.trim();
  }
  return null;
}

String? _threadIdFromState(GoRouterState state) {
  final pathId = state.pathParameters['threadId']?.trim();
  if (pathId != null && pathId.isNotEmpty) {
    return pathId;
  }
  final queryId = state.uri.queryParameters['threadId']?.trim();
  if (queryId != null && queryId.isNotEmpty) {
    return queryId;
  }
  final extra = state.extra;
  if (extra is MessagesPageArgs) {
    final threadId = extra.initialThreadId?.trim();
    if (threadId != null && threadId.isNotEmpty) {
      return threadId;
    }
  }
  if (extra is ChatThread && extra.id.trim().isNotEmpty) {
    return extra.id.trim();
  }
  if (extra is String && extra.trim().isNotEmpty) {
    return extra.trim();
  }
  return null;
}

String? _inviteGroupIdFromState(GoRouterState state) {
  final pathId = state.pathParameters['groupId']?.trim();
  if (pathId != null && pathId.isNotEmpty) {
    return pathId;
  }
  final queryId = state.uri.queryParameters['groupId']?.trim();
  if (queryId != null && queryId.isNotEmpty) {
    return queryId;
  }
  return null;
}

String? _inviteIdFromState(GoRouterState state) {
  final pathId = state.pathParameters['inviteId']?.trim();
  if (pathId != null && pathId.isNotEmpty) {
    return pathId;
  }
  final queryId = state.uri.queryParameters['inviteId']?.trim();
  if (queryId != null && queryId.isNotEmpty) {
    return queryId;
  }
  return null;
}

RehearsalBookingContext? _rehearsalContextFromState(GoRouterState state) {
  final extra = state.extra;
  if (extra is RehearsalBookingContext) {
    return extra;
  }

  final groupId = state.uri.queryParameters['groupId']?.trim() ?? '';
  final rehearsalId = state.uri.queryParameters['rehearsalId']?.trim() ?? '';
  final suggestedDateRaw = state.uri.queryParameters['suggestedDate']?.trim();
  if (groupId.isEmpty || rehearsalId.isEmpty || suggestedDateRaw == null) {
    return null;
  }
  final suggestedDate = DateTime.tryParse(suggestedDateRaw);
  if (suggestedDate == null) {
    return null;
  }
  final suggestedEndDateRaw = state.uri.queryParameters['suggestedEndDate']?.trim();
  final suggestedEndDate = suggestedEndDateRaw == null || suggestedEndDateRaw.isEmpty
      ? null
      : DateTime.tryParse(suggestedEndDateRaw);

  return RehearsalBookingContext(
    groupId: groupId,
    rehearsalId: rehearsalId,
    suggestedDate: suggestedDate,
    suggestedEndDate: suggestedEndDate,
  );
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen({required this.name, this.message});

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

class _MusicianDetailLoader extends StatelessWidget {
  const _MusicianDetailLoader({
    required this.musicianId,
    required this.location,
  });

  final String musicianId;
  final String location;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MusicianEntity?>(
      future: locate<MusiciansRepository>().findById(musicianId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return UserShellPage(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final musician = snapshot.data;
        if (snapshot.hasError || musician == null) {
          return _UnknownRouteScreen(
            name: location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro el musico solicitado.',
          );
        }
        return UserShellPage(child: MusicianDetailPage(musician: musician));
      },
    );
  }
}

class _AnnouncementDetailLoader extends StatelessWidget {
  const _AnnouncementDetailLoader({
    required this.announcementId,
    required this.location,
  });

  final String announcementId;
  final String location;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AnnouncementEntity>(
      future: locate<AnnouncementsRepository>().findById(announcementId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return UserShellPage(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return _UnknownRouteScreen(
            name: location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro el anuncio solicitado.',
          );
        }
        return UserShellPage(
          child: AnnouncementDetailPage(announcement: snapshot.data!),
        );
      },
    );
  }
}

class _EventDetailLoader extends StatelessWidget {
  const _EventDetailLoader({required this.eventId, required this.location});

  final String eventId;
  final String location;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EventEntity?>(
      future: locate<EventsRepository>().findById(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final event = snapshot.data;
        if (snapshot.hasError || event == null) {
          return _UnknownRouteScreen(
            name: location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro el evento solicitado.',
          );
        }
        return EventDetailPage(event: event);
      },
    );
  }
}

class _StudioRoomDetailData {
  const _StudioRoomDetailData({required this.room, required this.studioName});

  final RoomEntity room;
  final String studioName;
}

class _ChatThreadDetailLoader extends StatelessWidget {
  const _ChatThreadDetailLoader({
    required this.threadId,
    required this.location,
    this.initialThread,
  });

  final String threadId;
  final String location;
  final ChatThread? initialThread;

  Future<ChatThread?> _loadThread() async {
    final seedThread = initialThread;
    if (seedThread != null && seedThread.id == threadId) {
      return seedThread;
    }
    return locate<ChatRepository>().fetchThread(threadId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChatThread?>(
      future: _loadThread(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final thread = snapshot.data;
        if (snapshot.hasError || thread == null) {
          return _UnknownRouteScreen(
            name: location,
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'No se encontro el chat solicitado.',
          );
        }
        final currentUserId = locate<AuthRepository>().currentUser?.id ?? '';
        return ChatThreadDetailPage(
          thread: thread,
          threadTitle: thread.titleFor(currentUserId),
        );
      },
    );
  }
}

class _StudioRoomDetailLoader extends StatelessWidget {
  const _StudioRoomDetailLoader({
    required this.studioId,
    required this.roomId,
    required this.location,
    this.rehearsalContext,
  });

  final String studioId;
  final String roomId;
  final String location;
  final RehearsalBookingContext? rehearsalContext;

  Future<_StudioRoomDetailData?> _loadRoomDetail() async {
    final repository = locate<StudiosRepository>();
    final studio = await repository.getStudioById(studioId);
    final rooms = await repository.getRoomsByStudio(studioId);
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
          return _UnknownRouteScreen(
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

class _StudioRoomEditorLoader extends StatelessWidget {
  const _StudioRoomEditorLoader({
    required this.studioId,
    required this.roomId,
    required this.location,
  });

  final String studioId;
  final String roomId;
  final String location;

  Future<RoomEntity?> _loadRoom() async {
    final repository = locate<StudiosRepository>();
    final rooms = await repository.getRoomsByStudio(studioId);
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final room = snapshot.data;
        if (snapshot.hasError || room == null) {
          return _UnknownRouteScreen(
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
