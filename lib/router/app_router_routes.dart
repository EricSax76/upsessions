import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../core/locator/locator.dart';
import '../features/calendar/ui/pages/calendar_page.dart';
import '../features/contacts/ui/pages/contacts_page.dart';
import '../features/events/ui/pages/create_event_page.dart';
import '../features/events/ui/pages/events_page.dart';
import '../features/media/ui/pages/media_gallery_page.dart';
import '../features/notifications/ui/pages/notifications_page.dart';
import '../features/onboarding/ui/pages/app_welcome_page.dart';
import '../features/onboarding/ui/pages/musician_onboarding_page.dart';
import '../features/onboarding/ui/pages/book_onboarding_page.dart';
import '../features/onboarding/ui/pages/collaborate_onboarding_page.dart';
import '../features/onboarding/ui/pages/showcase_onboarding_page.dart';
import '../features/settings/ui/pages/help_page.dart';
import '../features/settings/ui/pages/settings_page.dart';
import '../home/splash/presentation/splash_page.dart';
import '../home/ui/pages/user_home_page.dart';
import '../home/ui/pages/user_shell_page.dart';
import '../modules/announcements/ui/pages/announcement_form_page.dart';
import '../modules/announcements/ui/pages/announcements_hub_page.dart';
import '../modules/auth/ui/pages/forgot_password_page.dart';
import '../modules/auth/ui/pages/login_page.dart';
import '../modules/auth/ui/pages/register_page.dart';
import '../modules/groups/ui/pages/groups_page.dart';
import '../modules/matching/ui/pages/matching_page.dart';
import '../modules/musicians/ui/pages/musicians_hub_page.dart';
import '../modules/profile/ui/pages/account_page.dart';
import '../modules/profile/ui/pages/profile_edit_page.dart';
import '../modules/profile/ui/pages/profile_overview_page.dart';
import '../modules/studios/ui/auth/studio_login_page.dart';
import '../modules/studios/ui/auth/studio_register_page.dart';
import '../modules/studios/ui/consumer/musician_bookings_page.dart';
import '../modules/studios/ui/provider/create_studio_page.dart';
import '../modules/studios/ui/provider/studio_dashboard_page.dart';
import 'app_router_builders.dart';

List<GoRoute> buildAppRoutes() {
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
      path: '/musicians/detail',
      redirect: (context, state) {
        final musicianId = state.uri.queryParameters['musicianId']?.trim();
        if (musicianId != null && musicianId.isNotEmpty) {
          return AppRoutes.musicianDetailPath(
            musicianId: musicianId,
            musicianName: '',
          );
        }
        return AppRoutes.musicians;
      },
    ),
    GoRoute(
      path: AppRoutes.musicianDetailRoute,
      builder: buildMusicianDetailRoute,
    ),
    GoRoute(
      path: AppRoutes.musicianDetailLegacyRoute,
      builder: buildMusicianDetailRoute,
    ),
    GoRoute(
      path: AppRoutes.announcements,
      builder: (context, state) => const AnnouncementsHubPage(),
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
      path: AppRoutes.announcementDetailRoute,
      builder: buildAnnouncementDetailRoute,
    ),
    GoRoute(
      path: AppRoutes.announcementForm,
      builder: (context, state) => AnnouncementFormPage(repository: locate()),
    ),
    GoRoute(
      path: AppRoutes.media,
      builder: (context, state) => const MediaGalleryPage(),
    ),
    GoRoute(path: AppRoutes.messages, builder: buildMessagesRoute),
    GoRoute(path: AppRoutes.messagesThreadRoute, builder: buildMessagesRoute),
    GoRoute(
      path: AppRoutes.messagesThreadDetailRoute,
      builder: buildChatThreadDetailRoute,
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
    GoRoute(path: AppRoutes.groupRoute, builder: buildGroupRoute),
    GoRoute(
      path: AppRoutes.groupRehearsalsRoute,
      builder: buildGroupRehearsalsRoute,
    ),
    GoRoute(
      path: AppRoutes.rehearsalDetailRoute,
      builder: buildRehearsalDetailRoute,
    ),
    GoRoute(path: AppRoutes.invite, builder: buildInviteAcceptRoute),
    GoRoute(path: AppRoutes.inviteRoute, builder: buildInviteAcceptRoute),
    GoRoute(path: AppRoutes.eventDetailRoute, builder: buildEventDetailRoute),
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
    GoRoute(path: AppRoutes.studios, builder: buildStudiosListRoute),
    GoRoute(path: AppRoutes.studiosRoomsRoute, builder: buildStudiosRoomsRoute),
    GoRoute(
      path: AppRoutes.studiosRoomCreateRoute,
      builder: buildStudiosRoomCreateRoute,
    ),
    GoRoute(
      path: AppRoutes.studiosRoomEditRoute,
      builder: buildStudiosRoomEditRoute,
    ),
    GoRoute(
      path: AppRoutes.studiosRoomDetailRoute,
      builder: buildStudiosRoomDetailRoute,
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
    GoRoute(path: AppRoutes.studiosProfile, builder: buildStudiosProfileRoute),
    GoRoute(
      path: AppRoutes.myBookings,
      builder: (context, state) =>
          const UserShellPage(child: MusicianBookingsPage()),
    ),
    GoRoute(
      path: AppRoutes.matching,
      builder: (context, state) => const UserShellPage(child: MatchingPage()),
    ),
  ];
}
