import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../modules/announcements/domain/announcement_entity.dart';
import '../modules/announcements/presentation/pages/announcement_detail_page.dart';
import '../modules/announcements/presentation/pages/announcement_form_page.dart';
import '../modules/announcements/presentation/pages/announcements_hub_page.dart';
import '../features/media/ui/pages/media_gallery_page.dart';
import '../features/calendar/presentation/pages/calendar_page.dart';
import '../modules/events/models/event_entity.dart';
import '../modules/events/ui/pages/event_detail_page.dart';
import '../modules/events/ui/pages/events_page.dart';
import '../features/messaging/presentation/pages/messages_page.dart';
import '../features/onboarding/presentation/pages/app_welcome_page.dart';
import '../features/onboarding/presentation/pages/musician_onboarding_page.dart';
import '../features/onboarding/presentation/pages/onboarding_story_pages.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/settings/presentation/pages/help_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../modules/rehearsals/ui/pages/group_rehearsals_page.dart';
import '../modules/rehearsals/ui/pages/group_page.dart';
import '../modules/rehearsals/ui/pages/invite_accept_page.dart';
import '../modules/rehearsals/ui/pages/rehearsal_detail_page.dart';
import '../modules/rehearsals/ui/pages/rehearsals_groups_page.dart';
import '../home/ui/pages/user_home_page.dart';
import '../modules/auth/ui/pages/forgot_password_page.dart';
import '../modules/auth/ui/pages/login_page.dart';
import '../modules/auth/ui/pages/register_page.dart';
import '../modules/musicians/models/musician_entity.dart';
import '../home/ui/pages/user_shell_page.dart';
import '../modules/musicians/ui/pages/musician_detail_page.dart';
import '../modules/musicians/ui/pages/musicians_hub_page.dart';
import '../modules/profile/ui/pages/account_page.dart';
import '../modules/profile/ui/pages/profile_edit_page.dart';
import '../modules/profile/ui/pages/profile_overview_page.dart';
import 'package:upsessions/core/locator/locator.dart';
import '../features/contacts/presentation/pages/contacts_page.dart';

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
          builder: (context, state) => const AppWelcomePage(),
        ),
        GoRoute(
          path: AppRoutes.onboardingStoryOne,
          builder: (context, state) => const CollaborateOnboardingPage(),
        ),
        GoRoute(
          path: AppRoutes.onboardingStoryTwo,
          builder: (context, state) => const ShowcaseOnboardingPage(),
        ),
        GoRoute(
          path: AppRoutes.onboardingStoryThree,
          builder: (context, state) => const BookOnboardingPage(),
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
          builder: (context, state) {
            final musician = state.extra;
            if (musician is MusicianEntity) {
              return UserShellPage(
                child: MusicianDetailPage(musician: musician),
              );
            }
            return _UnknownRouteScreen(
              name: state.uri.toString(),
              message: 'Missing MusicianEntity for ${state.uri}',
            );
          },
        ),
        GoRoute(
          path: AppRoutes.announcements,
          builder: (context, state) => const AnnouncementsHubPage(),
        ),
        GoRoute(
          path: AppRoutes.announcementDetail,
          builder: (context, state) {
            final announcement = state.extra;
            if (announcement is AnnouncementEntity) {
              return UserShellPage(
                child: AnnouncementDetailPage(announcement: announcement),
              );
            }
            return _UnknownRouteScreen(
              name: state.uri.toString(),
              message: 'Missing AnnouncementEntity for ${state.uri}',
            );
          },
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
          builder: (context, state) => const ContactsPage(),
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
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: AppRoutes.rehearsals,
          builder: (context, state) => const RehearsalsGroupsPage(),
        ),
        GoRoute(
          path: '/rehearsals/groups/:groupId',
          builder: (context, state) {
            final groupId = state.pathParameters['groupId'] ?? '';
            return GroupPage(groupId: groupId);
          },
        ),
        GoRoute(
          path: '/rehearsals/groups/:groupId/rehearsals',
          builder: (context, state) {
            final groupId = state.pathParameters['groupId'] ?? '';
            return GroupRehearsalsPage(groupId: groupId);
          },
        ),
        GoRoute(
          path: '/rehearsals/groups/:groupId/rehearsals/:rehearsalId',
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
          builder: (context, state) {
            final extra = state.extra;
            if (extra is EventEntity) {
              return EventDetailPage(event: extra);
            }
            return _UnknownRouteScreen(
              name: state.uri.toString(),
              message: 'Missing EventEntity for ${state.uri}',
            );
          },
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
