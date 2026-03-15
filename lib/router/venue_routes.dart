import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../core/locator/locator.dart';
import '../modules/auth/repositories/auth_repository.dart';
import '../modules/venues/cubits/manager_venues_cubit.dart';
import '../modules/venues/cubits/manager_venue_form_cubit.dart';
import '../modules/venues/models/venue_entity.dart';
import '../modules/venues/repositories/venues_repository.dart';
import '../modules/venues/ui/pages/manager_venue_form_page.dart';
import '../modules/venues/ui/pages/venue_dashboard_page.dart';
import '../modules/venues/ui/widgets/shell/venue_shell_page.dart';

NoTransitionPage<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

String? _requireVenueAuthRedirect() {
  final userId = locate<AuthRepository>().currentUser?.id.trim();
  if (userId == null || userId.isEmpty) {
    return AppRoutes.venuesAuthLogin;
  }
  return null;
}

List<RouteBase> buildVenueRoutes() {
  return [
    ShellRoute(
      builder: (context, state, child) => VenueShellPage(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.venuesDashboard,
          redirect: (context, state) => _requireVenueAuthRedirect(),
          pageBuilder: (context, state) => _noTransitionPage(
            state,
            BlocProvider(
              create: (context) => ManagerVenuesCubit(
                venuesRepository: locate<VenuesRepository>(),
                authRepository: locate<AuthRepository>(),
              ),
              child: const VenueDashboardPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.venuesDashboardVenueForm,
          redirect: (context, state) => _requireVenueAuthRedirect(),
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
          path: AppRoutes.venuesDashboardVenueEdit,
          redirect: (context, state) => _requireVenueAuthRedirect(),
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
      ],
    ),
  ];
}
