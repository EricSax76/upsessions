import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/router/app_router.dart';
import 'package:upsessions/router/app_router_routes.dart';

void main() {
  group('AppRouter', () {
    late GoRouter router;
    late List<GoRoute> goRoutes;

    List<GoRoute> extractGoRoutes(List<RouteBase> routes) {
      final result = <GoRoute>[];
      for (final route in routes) {
        if (route is GoRoute) {
          result.add(route);
          result.addAll(extractGoRoutes(route.routes));
        } else if (route is ShellRoute) {
          result.addAll(extractGoRoutes(route.routes));
        }
      }
      return result;
    }

    setUp(() {
      router = AppRouter().router;
      goRoutes = extractGoRoutes(router.configuration.routes);
    });

    test('starts on splash route', () {
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.splash);
    });

    test('registers every expected route path', () {
      final registeredPaths = goRoutes.map((route) => route.path).toSet();
      const expectedPaths = <String>[
        AppRoutes.splash,
        AppRoutes.welcome,
        AppRoutes.onboardingStoryOne,
        AppRoutes.onboardingStoryTwo,
        AppRoutes.onboardingStoryThree,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
        AppRoutes.musicianOnboarding,
        AppRoutes.userHome,
        AppRoutes.musicians,
        '/musicians/detail',
        AppRoutes.musicianDetailRoute,
        AppRoutes.musicianDetailLegacyRoute,
        AppRoutes.announcements,
        '/announcements/detail',
        AppRoutes.announcementDetailRoute,
        AppRoutes.announcementForm,
        AppRoutes.media,
        AppRoutes.messages,
        AppRoutes.events,
        AppRoutes.venues,
        '/events/detail',
        AppRoutes.eventDetailRoute,
        AppRoutes.profile,
        AppRoutes.profileEdit,
        AppRoutes.account,
        AppRoutes.settings,
        AppRoutes.help,
      ];

      final missing = expectedPaths
          .where((path) => !registeredPaths.contains(path))
          .toList();
      expect(
        missing,
        isEmpty,
        reason: 'AppRouter is missing definitions for: $missing',
      );
    });

    test('does not duplicate paths', () {
      final duplicates = <String>{};
      final seenPaths = <String>{};
      for (final route in goRoutes) {
        final path = route.path;
        if (!seenPaths.add(path)) {
          duplicates.add(path);
        }
      }
      expect(duplicates, isEmpty);
    });

    test('registers studio session routes before user shell', () {
      final routes = buildAppRoutes();
      final firstShellIndex = routes.indexWhere((route) => route is ShellRoute);
      final studioCreateIndex = routes.indexWhere(
        (route) =>
            route is GoRoute && route.path == AppRoutes.studiosRoomCreateRoute,
      );

      expect(firstShellIndex, isNonNegative);
      expect(studioCreateIndex, isNonNegative);
      expect(studioCreateIndex, lessThan(firstShellIndex));
    });
  });
}
