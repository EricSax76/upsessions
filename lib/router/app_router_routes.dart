import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../core/locator/locator.dart';
import '../features/calendar/ui/pages/calendar_page.dart';
import '../modules/contacts/ui/pages/contacts_page.dart';
import '../modules/events/ui/pages/create_event_page.dart';
import '../modules/events/ui/pages/events_page.dart';
import '../features/media/ui/pages/media_gallery_page.dart';
import '../features/legal/ui/pages/legal_pages.dart';
import '../modules/notifications/ui/pages/notifications_page.dart';
import '../features/onboarding/ui/pages/app_welcome_page.dart';
import '../features/onboarding/ui/pages/book_onboarding_page.dart';
import '../features/onboarding/ui/pages/collaborate_onboarding_page.dart';
import '../features/onboarding/ui/pages/showcase_onboarding_page.dart';
import '../features/settings/ui/pages/help_page.dart';
import '../features/settings/ui/pages/account_settings_page.dart';
import '../features/home/splash/presentation/splash_page.dart';
import '../features/home/ui/pages/user_home_page.dart';
import '../modules/events/repositories/events_repository.dart';
import '../modules/auth/repositories/auth_repository.dart';
import '../modules/messaging/repositories/chat_repository.dart';
import '../modules/notifications/repositories/invite_notifications_repository.dart';
import '../features/media/repositories/media_repository.dart';
import '../modules/announcements/ui/pages/announcement_form_page.dart';
import '../modules/announcements/ui/pages/announcements_hub_page.dart';
import '../modules/auth/ui/pages/forgot_password_page.dart';
import '../modules/auth/ui/pages/login_page.dart';
import '../modules/auth/ui/pages/register_page.dart';
import '../modules/groups/ui/pages/groups_page.dart';
import '../modules/profile/ui/pages/account_page.dart';
import '../modules/profile/ui/pages/profile_edit_page.dart';
import '../modules/musicians/repositories/affinity_options_repository.dart';
import '../modules/musicians/repositories/artist_image_repository.dart';
import '../modules/jam_sessions/ui/pages/jam_session_detail_page.dart';
import '../modules/jam_sessions/ui/pages/public_jam_sessions_page.dart';
import '../modules/jam_sessions/cubits/public_jam_sessions_cubit.dart';
import '../modules/jam_sessions/repositories/jam_sessions_repository.dart';
import '../modules/venues/cubits/public_venues_cubit.dart';
import '../modules/venues/ui/pages/public_venues_page.dart';
import '../modules/venues/repositories/venues_repository.dart';
import 'app_router_builders.dart';
import 'app_router_shell.dart';
import 'musician_routes.dart';
import 'studio_routes.dart';
import 'event_manager_routes.dart';

NoTransitionPage<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

List<RouteBase> buildAppRoutes() {
  return [
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
      path: AppRoutes.legalTerms,
      builder: (context, state) => const TermsPolicyPage(),
    ),
    GoRoute(
      path: AppRoutes.legalPrivacy,
      builder: (context, state) => const PrivacyPolicyPage(),
    ),
    GoRoute(
      path: AppRoutes.legalCookies,
      builder: (context, state) => const CookiesPolicyPage(),
    ),
    ...buildMusicianOuterRoutes(),
    // Studio provider routes must be evaluated before the user shell routes
    // to avoid collisions like `/studios/:studioId/rooms/new` being captured
    // by `/studios/:studioId/rooms/:roomId`.
    ...buildStudioOuterRoutes(),
    ShellRoute(
      builder: (context, state, child) => buildUserShell(context, child),
      routes: [
        GoRoute(
          path: AppRoutes.userHome,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const UserHomePage()),
        ),
        GoRoute(
          path: AppRoutes.announcements,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const AnnouncementsHubPage()),
        ),
        GoRoute(
          path: '/announcements/detail',
          redirect: (context, state) {
            final announcementId = state.uri.queryParameters['announcementId']
                ?.trim();
            if (announcementId != null && announcementId.isNotEmpty) {
              return AppRoutes.announcementDetailPath(announcementId);
            }
            return AppRoutes.announcements;
          },
        ),
        GoRoute(
          path: AppRoutes.announcementForm,
          builder: (context, state) => AnnouncementFormPage(
            repository: locate(),
            imageService: locate(),
          ),
        ),
        GoRoute(
          path: AppRoutes.announcementDetailRoute,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            buildAnnouncementDetailRoute(context, state),
          ),
        ),
        GoRoute(
          path: AppRoutes.media,
          builder: (context, state) =>
              MediaGalleryPage(repository: context.read<MediaRepository>()),
        ),
        GoRoute(
          path: AppRoutes.messages,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, buildMessagesRoute(context, state)),
        ),
        GoRoute(
          path: AppRoutes.messagesThreadRoute,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, buildMessagesRoute(context, state)),
        ),
        GoRoute(
          path: AppRoutes.messagesThreadDetailRoute,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            buildChatThreadDetailRoute(context, state),
          ),
        ),
        GoRoute(
          path: AppRoutes.contacts,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            ContactsPage(chatRepository: context.read<ChatRepository>()),
          ),
        ),
        GoRoute(
          path: AppRoutes.calendar,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const CalendarPage()),
        ),
        GoRoute(
          path: AppRoutes.events,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const EventsPage()),
        ),
        GoRoute(
          path: AppRoutes.jamSessions,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            BlocProvider(
              create: (context) => PublicJamSessionsCubit(
                repository: locate<JamSessionsRepository>(),
                authRepository: locate<AuthRepository>(),
              )..loadSessions(),
              child: const PublicJamSessionsPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.venues,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            BlocProvider(
              create: (context) => PublicVenuesCubit(
                venuesRepository: locate<VenuesRepository>(),
              ),
              child: const PublicVenuesPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.jamSessionDetailRoute,
          pageBuilder: (context, state) {
            final sessionId = state.pathParameters['sessionId'];
            if (sessionId == null || sessionId.isEmpty) {
              return _noTransitionPage(
                state,
                const Scaffold(
                  body: Center(child: Text('No se pudo abrir la jam session.')),
                ),
              );
            }
            return _noTransitionPage(
              state,
              JamSessionDetailPage(sessionId: sessionId),
            );
          },
        ),
        GoRoute(
          path: '/events/detail',
          redirect: (context, state) {
            final eventId = state.uri.queryParameters['eventId']?.trim();
            if (eventId != null && eventId.isNotEmpty) {
              return AppRoutes.eventDetailPath(eventId);
            }
            return AppRoutes.events;
          },
        ),
        GoRoute(
          path: AppRoutes.createEvent,
          builder: (context, state) => CreateEventPage(
            eventsRepository: context.read<EventsRepository>(),
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            NotificationsPage(
              chatRepository: context.read<ChatRepository>(),
              inviteNotificationsRepository: context
                  .read<InviteNotificationsRepository>(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.rehearsals,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const GroupsPage()),
        ),
        GoRoute(
          path: AppRoutes.groupRoute,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, buildGroupRoute(context, state)),
        ),
        GoRoute(
          path: AppRoutes.groupRehearsalsRoute,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            buildGroupRehearsalsRoute(context, state),
          ),
        ),
        GoRoute(
          path: AppRoutes.rehearsalDetailRoute,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            buildRehearsalDetailRoute(context, state),
          ),
        ),
        GoRoute(path: AppRoutes.invite, builder: buildInviteAcceptRoute),
        GoRoute(path: AppRoutes.inviteRoute, builder: buildInviteAcceptRoute),
        GoRoute(
          path: AppRoutes.eventDetailRoute,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, buildEventDetailRoute(context, state)),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const AccountPage()),
        ),
        GoRoute(
          path: AppRoutes.profileEdit,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            ProfileEditPage(
              affinityOptionsRepository: context
                  .read<AffinityOptionsRepository>(),
              artistImageRepository: context.read<ArtistImageRepository>(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.account,
          redirect: (context, state) => AppRoutes.profile,
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const AccountSettingsPage()),
        ),
        GoRoute(
          path: AppRoutes.help,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const HelpPage()),
        ),
        ...buildMusicianShellRoutes(),
        ...buildStudioShellRoutes(),
      ],
    ),
    ...buildEventManagerRoutes(),
  ];
}
