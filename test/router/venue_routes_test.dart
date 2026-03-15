import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/router/venue_routes.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockBuildContext extends Mock implements BuildContext {}

class _MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockBuildContext context;
  late _MockGoRouterState state;

  GoRoute routeByPath(List<RouteBase> routes, String path) {
    for (final route in routes) {
      if (route is GoRoute && route.path == path) {
        return route;
      }
      if (route is ShellRoute) {
        try {
          return routeByPath(route.routes, path);
        } on StateError {
          // Keep searching sibling routes.
        }
      }
    }
    throw StateError('Route not found for $path');
  }

  setUp(() async {
    authRepository = _MockAuthRepository();
    context = _MockBuildContext();
    state = _MockGoRouterState();
    await getIt.reset();
    getIt.registerSingleton<AuthRepository>(authRepository);
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('buildVenueRoutes auth guards', () {
    final protectedPaths = <String>[
      AppRoutes.venuesDashboard,
      AppRoutes.venuesDashboardVenueForm,
      AppRoutes.venuesDashboardVenueEdit,
    ];

    test('redirects protected venue routes to login when unauthenticated', () {
      when(() => authRepository.currentUser).thenReturn(null);
      final routes = buildVenueRoutes();

      for (final path in protectedPaths) {
        final route = routeByPath(routes, path);
        final redirect = route.redirect;
        expect(redirect, isNotNull, reason: 'Missing redirect for $path');
        expect(
          redirect!(context, state),
          AppRoutes.venuesAuthLogin,
          reason: 'Unexpected redirect target for $path',
        );
      }
    });

    test('allows protected venue routes when authenticated', () {
      when(() => authRepository.currentUser).thenReturn(
        UserEntity(
          id: 'manager-1',
          email: 'manager@test.com',
          displayName: 'Manager',
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      final routes = buildVenueRoutes();

      for (final path in protectedPaths) {
        final route = routeByPath(routes, path);
        final redirect = route.redirect;
        expect(redirect, isNotNull, reason: 'Missing redirect for $path');
        expect(
          redirect!(context, state),
          isNull,
          reason: 'Unexpected redirect for authenticated user on $path',
        );
      }
    });
  });
}
