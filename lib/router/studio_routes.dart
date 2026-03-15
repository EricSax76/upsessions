import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../core/locator/locator.dart';
import '../modules/auth/repositories/auth_repository.dart';
import '../modules/studios/cubits/my_studio_cubit.dart';
import '../modules/notifications/models/notification_scenario.dart';
import '../modules/notifications/ui/pages/notification_center_page.dart';
import '../modules/studios/repositories/studios_repository.dart';
import '../modules/studios/repositories/studio_notifications_repository.dart';
import '../modules/studios/ui/consumer/musician_bookings_page.dart';
import '../modules/studios/ui/pages/studio_login_page.dart';
import '../modules/studios/ui/pages/studio_register_page.dart';
import '../modules/studios/ui/provider/create_studio_page.dart';
import '../modules/studios/ui/provider/studio_dashboard_page.dart';
import '../modules/studios/ui/widgets/studio_shell_page.dart';
import 'app_router_builders.dart';

NoTransitionPage<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

List<RouteBase> buildStudioOuterRoutes() {
  return [
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
      redirect: (context, state) {
        final userId = locate<AuthRepository>().currentUser?.id.trim();
        if (userId == null || userId.isEmpty) {
          return AppRoutes.studiosLogin;
        }
        return null;
      },
      builder: (context, state) {
        final ownerId = locate<AuthRepository>().currentUser?.id ?? '';
        return BlocProvider(
          create: (context) =>
              MyStudioCubit(repository: locate<StudiosRepository>()),
          child: StudioShellPage(child: CreateStudioPage(ownerId: ownerId)),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.studiosDashboard,
      pageBuilder: (context, state) {
        final authRepo = locate<AuthRepository>();
        final userId = authRepo.currentUser?.id;
        return _noTransitionPage(
          state,
          BlocProvider(
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
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.studiosProfile,
      pageBuilder: (context, state) =>
          _noTransitionPage(state, buildStudiosProfileRoute(context, state)),
    ),
    GoRoute(
      path: AppRoutes.studiosRoomCreateRoute,
      pageBuilder: (context, state) =>
          _noTransitionPage(state, buildStudiosRoomCreateRoute(context, state)),
    ),
    GoRoute(
      path: AppRoutes.studiosRoomEditRoute,
      pageBuilder: (context, state) =>
          _noTransitionPage(state, buildStudiosRoomEditRoute(context, state)),
    ),
    GoRoute(
      path: AppRoutes.studiosNotifications,
      redirect: (context, state) {
        final userId = locate<AuthRepository>().currentUser?.id.trim();
        if (userId == null || userId.isEmpty) return AppRoutes.studiosLogin;
        return null;
      },
      pageBuilder: (context, state) => _noTransitionPage(
        state,
        StudioShellPage(
          child: NotificationCenterPage(
            audience: NotificationAudience.studio,
            studioNotificationsRepository:
                locate<StudioNotificationsRepository>(),
          ),
        ),
      ),
    ),
  ];
}

List<RouteBase> buildStudioShellRoutes() {
  return [
    GoRoute(
      path: AppRoutes.studios,
      pageBuilder: (context, state) =>
          _noTransitionPage(state, buildStudiosListRoute(context, state)),
    ),
    GoRoute(
      path: AppRoutes.studiosRoomsRoute,
      pageBuilder: (context, state) =>
          _noTransitionPage(state, buildStudiosRoomsRoute(context, state)),
    ),
    GoRoute(
      path: AppRoutes.studiosRoomDetailRoute,
      pageBuilder: (context, state) =>
          _noTransitionPage(state, buildStudiosRoomDetailRoute(context, state)),
    ),
    GoRoute(
      path: AppRoutes.myBookings,
      pageBuilder: (context, state) =>
          _noTransitionPage(state, const MusicianBookingsPage()),
    ),
  ];
}
