import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../core/locator/locator.dart';
import '../features/calendar/ui/pages/calendar_page.dart';
import '../modules/contacts/ui/pages/contacts_page.dart';
import '../features/events/ui/pages/create_event_page.dart';
import '../features/events/ui/pages/events_page.dart';
import '../features/media/ui/pages/media_gallery_page.dart';
import '../modules/notifications/ui/pages/notifications_page.dart';
import '../features/onboarding/ui/pages/app_welcome_page.dart';
import '../features/onboarding/ui/pages/musician_onboarding_page.dart';
import '../features/onboarding/ui/pages/book_onboarding_page.dart';
import '../features/onboarding/ui/pages/collaborate_onboarding_page.dart';
import '../features/onboarding/ui/pages/showcase_onboarding_page.dart';
import '../features/settings/ui/pages/help_page.dart';
import '../features/settings/ui/pages/account_settings_page.dart';
import '../features/home/splash/presentation/splash_page.dart';
import '../features/home/ui/pages/user_home_page.dart';
import '../features/home/ui/pages/user_shell_page.dart';
import '../modules/groups/repositories/groups_repository.dart';
import '../features/events/repositories/events_repository.dart';
import '../modules/auth/repositories/auth_repository.dart';
import '../modules/messaging/repositories/chat_repository.dart';
import '../modules/notifications/repositories/invite_notifications_repository.dart';
import '../modules/contacts/cubits/liked_musicians_cubit.dart';
import '../features/media/repositories/media_repository.dart';
import '../modules/announcements/ui/pages/announcement_form_page.dart';
import '../modules/announcements/ui/pages/announcements_hub_page.dart';
import '../modules/musicians/repositories/affinity_options_repository.dart';
import '../modules/musicians/repositories/artist_image_repository.dart';
import '../modules/auth/ui/pages/forgot_password_page.dart';
import '../modules/auth/ui/pages/login_page.dart';
import '../modules/auth/ui/pages/register_page.dart';
import '../modules/groups/ui/pages/groups_page.dart';
import '../modules/matching/ui/pages/matching_page.dart';
import '../modules/musicians/ui/pages/musicians_hub_page.dart';
import '../modules/profile/ui/pages/account_page.dart';
import '../modules/profile/ui/pages/profile_edit_page.dart';
import '../modules/studios/ui/pages/studio_login_page.dart';
import '../modules/studios/ui/pages/studio_register_page.dart';
import '../modules/studios/ui/consumer/musician_bookings_page.dart';
import '../modules/studios/ui/provider/create_studio_page.dart';
import '../modules/studios/ui/provider/studio_dashboard_page.dart';
import '../modules/studios/ui/widgets/studio_shell_page.dart';
import '../modules/studios/cubits/my_studio_cubit.dart';
import '../modules/studios/repositories/studios_repository.dart';
import '../modules/event_manager/ui/pages/manager_login_page.dart';
import '../modules/event_manager/ui/pages/manager_register_page.dart';
import '../modules/event_manager/ui/pages/manager_dashboard_page.dart';
import '../modules/event_manager/ui/pages/manager_events_page.dart';
import '../modules/event_manager/ui/pages/manager_event_detail_page.dart';
import '../modules/event_manager/ui/pages/manager_event_form_page.dart';
import '../modules/jam_sessions/ui/pages/jam_sessions_page.dart';
import '../modules/jam_sessions/ui/pages/jam_session_detail_page.dart';
import '../modules/jam_sessions/ui/pages/jam_session_form_page.dart';
import '../modules/event_manager/ui/pages/manager_agenda_page.dart';
import '../modules/event_manager/ui/pages/hire_musicians_page.dart';
import '../modules/event_manager/ui/pages/gig_offers_page.dart';
import '../modules/event_manager/ui/widgets/hiring/gig_offer_form.dart';
import '../modules/event_manager/ui/pages/manager_profile_page.dart';
import '../modules/event_manager/ui/pages/manager_settings_page.dart';
import '../modules/event_manager/ui/widgets/shell/manager_shell_page.dart';
import '../modules/event_manager/cubits/event_manager_auth_cubit.dart';
import '../modules/event_manager/repositories/event_manager_repository.dart';
import '../modules/event_manager/cubits/manager_dashboard_cubit.dart';
import '../modules/event_manager/cubits/manager_events_cubit.dart';
import '../modules/event_manager/cubits/manager_event_form_cubit.dart';
import '../modules/jam_sessions/cubits/jam_sessions_cubit.dart';
import '../modules/jam_sessions/cubits/jam_session_form_cubit.dart';
import '../modules/event_manager/cubits/manager_agenda_cubit.dart';
import '../modules/event_manager/repositories/manager_events_repository.dart';
import '../modules/jam_sessions/repositories/jam_sessions_repository.dart';
import '../modules/event_manager/cubits/musician_requests_cubit.dart';
import '../modules/event_manager/cubits/gig_offers_cubit.dart';
import '../modules/event_manager/cubits/gig_offer_form_cubit.dart';
import '../modules/event_manager/repositories/musician_requests_repository.dart';
import '../modules/event_manager/repositories/gig_offers_repository.dart';
import '../modules/event_manager/cubits/hire_musicians_cubit.dart';
import '../modules/musicians/repositories/musicians_repository.dart';
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
      builder: (context, state) => Scaffold(
        body: MusicianOnboardingPage(
          affinityOptionsRepository: context.read<AffinityOptionsRepository>(),
          artistImageRepository: context.read<ArtistImageRepository>(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.userHome,
      builder: (context, state) => UserHomePage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
      ),
    ),
    GoRoute(
      path: AppRoutes.musicians,
      builder: (context, state) => MusiciansHubPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
      ),
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
      builder: (context, state) => AnnouncementsHubPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
      ),
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
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: AnnouncementFormPage(
          repository: locate(),
          imageService: locate(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.announcementDetailRoute,
      builder: buildAnnouncementDetailRoute,
    ),
    GoRoute(
      path: AppRoutes.media,
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: MediaGalleryPage(repository: context.read<MediaRepository>()),
      ),
    ),
    GoRoute(path: AppRoutes.messages, builder: buildMessagesRoute),
    GoRoute(path: AppRoutes.messagesThreadRoute, builder: buildMessagesRoute),
    GoRoute(
      path: AppRoutes.messagesThreadDetailRoute,
      builder: buildChatThreadDetailRoute,
    ),
    GoRoute(
      path: AppRoutes.contacts,
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: ContactsPage(chatRepository: context.read<ChatRepository>()),
      ),
    ),
    GoRoute(
      path: AppRoutes.calendar,
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: const CalendarPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.events,
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: const EventsPage(),
      ),
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
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: CreateEventPage(
          eventsRepository: context.read<EventsRepository>(),
          authRepository: context.read<AuthRepository>(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: NotificationsPage(
          chatRepository: context.read<ChatRepository>(),
          inviteNotificationsRepository: context
              .read<InviteNotificationsRepository>(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.rehearsals,
      builder: (context, state) => GroupsPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
      ),
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
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: const AccountPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.profileEdit,
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: ProfileEditPage(
          affinityOptionsRepository: context.read<AffinityOptionsRepository>(),
          artistImageRepository: context.read<ArtistImageRepository>(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.account,
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: const AccountPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: const AccountSettingsPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.help,
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: const HelpPage(),
      ),
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
      builder: (context, state) {
        return BlocProvider(
          create: (context) =>
              MyStudioCubit(repository: locate<StudiosRepository>()),
          child: const StudioShellPage(child: CreateStudioPage()),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.studiosDashboard,
      builder: (context, state) {
        final authRepo = locate<AuthRepository>();
        final userId = authRepo.currentUser?.id;
        return BlocProvider(
          create: (context) {
            final cubit = MyStudioCubit(
              repository: locate<StudiosRepository>(),
            );
            if (userId != null) {
              cubit.loadMyStudio(userId);
            }
            return cubit;
          },
          child: const StudioShellPage(child: StudioDashboardPage()),
        );
      },
    ),
    GoRoute(path: AppRoutes.studiosProfile, builder: buildStudiosProfileRoute),
    GoRoute(
      path: AppRoutes.myBookings,
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: const MusicianBookingsPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.matching,
      builder: (context, state) => UserShellPage(
        groupsRepository: context.read<GroupsRepository>(),
        chatRepository: context.read<ChatRepository>(),
        inviteNotificationsRepository: context
            .read<InviteNotificationsRepository>(),
        likedMusiciansCubit: context.read<LikedMusiciansCubit>(),
        child: const MatchingPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerLogin,
      builder: (context, state) => const ManagerLoginPage(),
    ),
    GoRoute(
      path: AppRoutes.eventManagerRegister,
      builder: (context, state) => const ManagerRegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.eventManagerDashboard,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => EventManagerAuthCubit(
              authRepository: locate<AuthRepository>(),
              managerRepository: locate<EventManagerRepository>(),
            )..loadProfile(),
          ),
          BlocProvider(
            create: (context) => ManagerDashboardCubit(
              eventsRepository: locate<ManagerEventsRepository>(),
              authRepository: locate<AuthRepository>(),
            ),
          ),
        ],
        child: const ManagerShellPage(child: ManagerDashboardPage()),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerEvents,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => EventManagerAuthCubit(
              authRepository: locate<AuthRepository>(),
              managerRepository: locate<EventManagerRepository>(),
            )..loadProfile(),
          ),
          BlocProvider(
            create: (context) => ManagerEventsCubit(
              repository: locate<ManagerEventsRepository>(),
              authRepository: locate<AuthRepository>(),
            ),
          ),
        ],
        child: const ManagerShellPage(child: ManagerEventsPage()),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerEventForm,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => EventManagerAuthCubit(
              authRepository: locate<AuthRepository>(),
              managerRepository: locate<EventManagerRepository>(),
            )..loadProfile(),
          ),
          BlocProvider(
            create: (context) => ManagerEventFormCubit(
              repository: locate<ManagerEventsRepository>(),
            ),
          ),
        ],
        child: const ManagerShellPage(child: ManagerEventFormPage()),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerEventDetail,
      builder: (context, state) => BlocProvider(
        create: (context) => EventManagerAuthCubit(
          authRepository: locate<AuthRepository>(),
          managerRepository: locate<EventManagerRepository>(),
        )..loadProfile(),
        child: ManagerShellPage(
          child: ManagerEventDetailPage(eventId: state.pathParameters['eventId']!),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerJamSessions,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => EventManagerAuthCubit(
              authRepository: locate<AuthRepository>(),
              managerRepository: locate<EventManagerRepository>(),
            )..loadProfile(),
          ),
          BlocProvider(
            create: (context) => JamSessionsCubit(
              repository: locate<JamSessionsRepository>(),
              authRepository: locate<AuthRepository>(),
            ),
          ),
        ],
        child: const ManagerShellPage(child: JamSessionsPage()),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerJamSessionForm,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => EventManagerAuthCubit(
              authRepository: locate<AuthRepository>(),
              managerRepository: locate<EventManagerRepository>(),
            )..loadProfile(),
          ),
          BlocProvider(
            create: (context) => JamSessionFormCubit(
              repository: locate<JamSessionsRepository>(),
            ),
          ),
        ],
        child: const ManagerShellPage(child: JamSessionFormPage()),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerJamSessionDetail,
      builder: (context, state) => BlocProvider(
        create: (context) => EventManagerAuthCubit(
          authRepository: locate<AuthRepository>(),
          managerRepository: locate<EventManagerRepository>(),
        )..loadProfile(),
        child: ManagerShellPage(
          child: JamSessionDetailPage(sessionId: state.pathParameters['sessionId']!),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerAgenda,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => EventManagerAuthCubit(
              authRepository: locate<AuthRepository>(),
              managerRepository: locate<EventManagerRepository>(),
            )..loadProfile(),
          ),
          BlocProvider(
            create: (context) => ManagerAgendaCubit(
              eventsRepository: locate<ManagerEventsRepository>(),
              jamSessionsRepository: locate<JamSessionsRepository>(),
              authRepository: locate<AuthRepository>(),
            ),
          ),
        ],
        child: const ManagerShellPage(child: ManagerAgendaPage()),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerHireMusicians,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => EventManagerAuthCubit(
              authRepository: locate<AuthRepository>(),
              managerRepository: locate<EventManagerRepository>(),
            )..loadProfile(),
          ),
          BlocProvider(
            create: (context) => MusicianRequestsCubit(
              repository: locate<MusicianRequestsRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => HireMusiciansCubit(
              repository: locate<MusiciansRepository>(),
            ),
          ),
        ],
        child: const ManagerShellPage(child: HireMusiciansPage()),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerGigOffers,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => EventManagerAuthCubit(
              authRepository: locate<AuthRepository>(),
              managerRepository: locate<EventManagerRepository>(),
            )..loadProfile(),
          ),
          BlocProvider(
            create: (context) => GigOffersCubit(
              repository: locate<GigOffersRepository>(),
            ),
          ),
        ],
        child: const ManagerShellPage(child: GigOffersPage()),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerGigOfferForm,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => EventManagerAuthCubit(
              authRepository: locate<AuthRepository>(),
              managerRepository: locate<EventManagerRepository>(),
            )..loadProfile(),
          ),
          BlocProvider(
            create: (context) => GigOfferFormCubit(
              repository: locate<GigOffersRepository>(),
            ),
          ),
        ],
        child: const ManagerShellPage(child: GigOfferForm()),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerProfile,
      builder: (context, state) => BlocProvider(
        create: (context) => EventManagerAuthCubit(
          authRepository: locate<AuthRepository>(),
          managerRepository: locate<EventManagerRepository>(),
        )..loadProfile(),
        child: const ManagerShellPage(child: ManagerProfilePage()),
      ),
    ),
    GoRoute(
      path: AppRoutes.eventManagerSettings,
      builder: (context, state) => BlocProvider(
        create: (context) => EventManagerAuthCubit(
          authRepository: locate<AuthRepository>(),
          managerRepository: locate<EventManagerRepository>(),
        )..loadProfile(),
        child: const ManagerShellPage(child: ManagerSettingsPage()),
      ),
    ),
  ];
}
