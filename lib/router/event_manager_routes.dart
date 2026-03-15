import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../core/locator/locator.dart';
import '../modules/auth/repositories/auth_repository.dart';
import '../modules/event_manager/cubits/event_manager_auth_cubit.dart';
import '../modules/event_manager/cubits/gig_offer_form_cubit.dart';
import '../modules/event_manager/cubits/gig_offers_cubit.dart';
import '../modules/event_manager/cubits/hire_musicians_cubit.dart';
import '../modules/event_manager/cubits/manager_agenda_cubit.dart';
import '../modules/event_manager/cubits/manager_dashboard_cubit.dart';
import '../modules/event_manager/cubits/manager_event_form_cubit.dart';
import '../modules/event_manager/cubits/manager_events_cubit.dart';
import '../modules/event_manager/cubits/musician_requests_cubit.dart';
import '../modules/event_manager/repositories/event_manager_repository.dart';
import '../modules/event_manager/repositories/gig_offers_repository.dart';
import '../modules/event_manager/repositories/manager_events_repository.dart';
import '../modules/event_manager/repositories/musician_requests_repository.dart';
import '../modules/event_manager/repositories/manager_notifications_repository.dart';
import '../modules/event_manager/ui/pages/gig_offers_page.dart';
import '../modules/event_manager/ui/pages/hire_musicians_page.dart';
import '../modules/event_manager/ui/pages/manager_agenda_page.dart';
import '../modules/event_manager/ui/pages/manager_dashboard_page.dart';
import '../modules/event_manager/ui/pages/manager_event_detail_page.dart';
import '../modules/event_manager/ui/pages/manager_event_form_page.dart';
import '../modules/event_manager/ui/pages/manager_events_page.dart';
import '../modules/event_manager/ui/pages/manager_login_page.dart';
import '../modules/event_manager/ui/pages/manager_profile_page.dart';
import '../modules/event_manager/ui/pages/manager_register_page.dart';
import '../modules/event_manager/ui/pages/manager_settings_page.dart';
import '../modules/event_manager/ui/widgets/hiring/gig_offer_form.dart';
import '../modules/event_manager/ui/widgets/shell/manager_shell_page.dart';
import '../modules/jam_sessions/cubits/jam_session_form_cubit.dart';
import '../modules/jam_sessions/cubits/jam_sessions_cubit.dart';
import '../modules/jam_sessions/repositories/jam_sessions_repository.dart';
import '../modules/jam_sessions/ui/pages/jam_session_detail_page.dart';
import '../modules/jam_sessions/ui/pages/jam_session_form_page.dart';
import '../modules/jam_sessions/ui/pages/jam_sessions_page.dart';
import '../modules/musicians/repositories/musicians_repository.dart';
import '../modules/notifications/models/notification_scenario.dart';
import '../modules/notifications/ui/pages/notification_center_page.dart';
import '../modules/venues/cubits/venues_catalog_cubit.dart';
import '../modules/venues/cubits/manager_venues_cubit.dart';
import '../modules/venues/cubits/manager_venue_form_cubit.dart';
import '../modules/venues/models/venue_entity.dart';
import '../modules/venues/repositories/venues_repository.dart';
import '../modules/venues/ui/pages/manager_venue_form_page.dart';
import '../modules/venues/ui/pages/manager_venues_page.dart';

NoTransitionPage<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

List<RouteBase> buildEventManagerRoutes() {
  return [
    GoRoute(
      path: AppRoutes.eventManagerLogin,
      builder: (context, state) => const ManagerLoginPage(),
    ),
    GoRoute(
      path: AppRoutes.eventManagerRegister,
      builder: (context, state) => const ManagerRegisterPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => BlocProvider(
        create: (context) => EventManagerAuthCubit(
          authRepository: locate<AuthRepository>(),
          managerRepository: locate<EventManagerRepository>(),
        )..loadProfile(),
        child: ManagerShellPage(child: child),
      ),
      routes: [
        GoRoute(
          path: AppRoutes.eventManagerDashboard,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            BlocProvider(
              create: (context) => ManagerDashboardCubit(
                eventsRepository: locate<ManagerEventsRepository>(),
                authRepository: locate<AuthRepository>(),
              ),
              child: const ManagerDashboardPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerEvents,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            BlocProvider(
              create: (context) => ManagerEventsCubit(
                repository: locate<ManagerEventsRepository>(),
                authRepository: locate<AuthRepository>(),
              ),
              child: const ManagerEventsPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerEventForm,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            BlocProvider(
              create: (context) => ManagerEventFormCubit(
                repository: locate<ManagerEventsRepository>(),
              ),
              child: const ManagerEventFormPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerEventDetail,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            ManagerEventDetailPage(eventId: state.pathParameters['eventId']!),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerJamSessions,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            BlocProvider(
              create: (context) => JamSessionsCubit(
                repository: locate<JamSessionsRepository>(),
                authRepository: locate<AuthRepository>(),
              ),
              child: const JamSessionsPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerJamSessionForm,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => JamSessionFormCubit(
                    repository: locate<JamSessionsRepository>(),
                  ),
                ),
                BlocProvider(
                  create: (context) => VenuesCatalogCubit(
                    venuesRepository: locate<VenuesRepository>(),
                    authRepository: locate<AuthRepository>(),
                  )..loadSelectableVenues(),
                ),
              ],
              child: const JamSessionFormPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerJamSessionDetail,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            JamSessionDetailPage(sessionId: state.pathParameters['sessionId']!),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerVenues,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            BlocProvider(
              create: (context) => ManagerVenuesCubit(
                venuesRepository: locate<VenuesRepository>(),
                authRepository: locate<AuthRepository>(),
              ),
              child: const ManagerVenuesPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerVenueForm,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            BlocProvider(
              create: (context) => ManagerVenueFormCubit(
                venuesRepository: locate<VenuesRepository>(),
                authRepository: locate<AuthRepository>(),
              )..initialize(),
              child: const ManagerVenueFormPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerVenueEdit,
          pageBuilder: (context, state) {
            final venueId = state.pathParameters['venueId'] ?? '';
            final extra = state.extra;
            final initialVenue = extra is VenueEntity ? extra : null;
            return _noTransitionPage(
              state,
              BlocProvider(
                create: (context) => ManagerVenueFormCubit(
                  venuesRepository: locate<VenuesRepository>(),
                  authRepository: locate<AuthRepository>(),
                )..initialize(venueId: venueId, initialVenue: initialVenue),
                child: const ManagerVenueFormPage(),
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.eventManagerAgenda,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            BlocProvider(
              create: (context) => ManagerAgendaCubit(
                eventsRepository: locate<ManagerEventsRepository>(),
                jamSessionsRepository: locate<JamSessionsRepository>(),
                authRepository: locate<AuthRepository>(),
              ),
              child: const ManagerAgendaPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerHireMusicians,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            MultiBlocProvider(
              providers: [
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
              child: const HireMusiciansPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerGigOffers,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            BlocProvider(
              create: (context) =>
                  GigOffersCubit(repository: locate<GigOffersRepository>()),
              child: const GigOffersPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerGigOfferForm,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            BlocProvider(
              create: (context) =>
                  GigOfferFormCubit(repository: locate<GigOffersRepository>()),
              child: const GigOfferForm(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.eventManagerProfile,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const ManagerProfilePage()),
        ),
        GoRoute(
          path: AppRoutes.eventManagerSettings,
          pageBuilder: (context, state) =>
              _noTransitionPage(state, const ManagerSettingsPage()),
        ),
        GoRoute(
          path: AppRoutes.eventManagerNotifications,
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            NotificationCenterPage(
              audience: NotificationAudience.eventManager,
              managerNotificationsRepository:
                  locate<ManagerNotificationsRepository>(),
            ),
          ),
        ),
      ],
    ),
  ];
}
