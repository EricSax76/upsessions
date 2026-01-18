import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../modules/announcements/domain/announcement_entity.dart';
import '../modules/announcements/data/announcements_repository.dart';
import '../modules/announcements/presentation/pages/announcement_detail_page.dart';
import '../modules/announcements/presentation/pages/announcement_form_page.dart';
import '../modules/announcements/presentation/pages/announcements_hub_page.dart';
import '../features/media/ui/pages/media_gallery_page.dart';
import '../features/calendar/ui/pages/calendar_page.dart';
import '../features/events/data/events_repository.dart';
import '../features/events/domain/event_entity.dart';
import '../features/events/presentation/pages/create_event_page.dart';
import '../features/events/presentation/pages/event_detail_page.dart';
import '../features/events/presentation/pages/events_page.dart';
import '../features/messaging/ui/pages/messages_page.dart';
import '../features/onboarding/ui/pages/app_welcome_page.dart';
import '../features/onboarding/ui/pages/musician_onboarding_page.dart';
import '../features/onboarding/ui/pages/onboarding_story_pages.dart';
import '../features/notifications/ui/pages/notifications_page.dart';
import '../features/settin/ui/pages/help_page.dart';
import '../features/settin/ui/pages/settings_page.dart';
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
import '../modules/musicians/models/musician_entity.dart';
import '../modules/musicians/repositories/musicians_repository.dart';
import '../home/ui/pages/user_shell_page.dart';
import '../modules/musicians/ui/pages/musician_detail_page.dart';
import '../modules/musicians/ui/pages/musicians_hub_page.dart';
import '../modules/profile/ui/pages/account_page.dart';
import '../modules/profile/ui/pages/profile_edit_page.dart';
import '../modules/profile/ui/pages/profile_overview_page.dart';
import 'package:upsessions/core/locator/locator.dart';
import '../features/contacts/ui/pages/contacts_page.dart';

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
        GoRoute(
          path: AppRoutes.musicianDetail,
          builder: _buildMusicianDetail,
        ),
        GoRoute(
          path: AppRoutes.musicianDetailRoute,
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
          builder: (context, state) {
            final extra = state.extra;
            if (extra is MessagesPageArgs) {
              return MessagesPage(initialThreadId: extra.initialThreadId);
            }
            return const MessagesPage();
          },
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
          builder: (context, state) => const CreateEventPage(),
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
          builder: (context, state) {
            final groupId = state.uri.queryParameters['groupId'] ?? '';
            final inviteId = state.uri.queryParameters['inviteId'] ?? '';
            return InviteAcceptPage(groupId: groupId, inviteId: inviteId);
          },
        ),
        GoRoute(
          path: AppRoutes.eventDetail,
          builder: _buildEventDetail,
        ),
        GoRoute(
          path: AppRoutes.eventDetailRoute,
          builder: _buildEventDetail,
        ),
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
    return UserShellPage(
      child: MusicianDetailPage(musician: musician),
    );
  }
  final musicianId = state.pathParameters['musicianId'];
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
  final announcementId = state.pathParameters['announcementId'];
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
    return EventDetailPage(event: extra);
  }
  final eventId = state.pathParameters['eventId'];
  if (eventId != null && eventId.isNotEmpty) {
    return _EventDetailLoader(eventId: eventId, location: state.uri.toString());
  }
  return _UnknownRouteScreen(
    name: state.uri.toString(),
    message: 'Missing EventEntity for ${state.uri}',
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
        return UserShellPage(
          child: MusicianDetailPage(musician: musician),
        );
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
