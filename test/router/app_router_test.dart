import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/router/app_router.dart';

void main() {
  group('AppRouter', () {
    late GoRouter router;
    late List<GoRoute> goRoutes;

    setUp(() {
      router = AppRouter().router;
      goRoutes = router.configuration.routes.whereType<GoRoute>().toList();
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
        AppRoutes.musicianDetail,
        AppRoutes.musicianDetailRoute,
        AppRoutes.announcements,
        AppRoutes.announcementDetail,
        AppRoutes.announcementDetailRoute,
        AppRoutes.announcementForm,
        AppRoutes.media,
        AppRoutes.messages,
        AppRoutes.events,
        AppRoutes.eventDetail,
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
  });
}
