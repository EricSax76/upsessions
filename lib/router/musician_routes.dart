import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../modules/matching/ui/pages/matching_page.dart';
import '../modules/musicians/repositories/affinity_options_repository.dart';
import '../modules/musicians/repositories/artist_image_repository.dart';
import '../modules/musicians/ui/pages/musicians_hub_page.dart';
import '../features/onboarding/ui/pages/musician_onboarding_page.dart';
import 'app_router_builders.dart';

NoTransitionPage<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

List<RouteBase> buildMusicianOuterRoutes() {
  return [
    GoRoute(
      path: AppRoutes.musicianOnboarding,
      builder: (context, state) => Scaffold(
        body: MusicianOnboardingPage(
          affinityOptionsRepository: context.read<AffinityOptionsRepository>(),
          artistImageRepository: context.read<ArtistImageRepository>(),
        ),
      ),
    ),
  ];
}

List<RouteBase> buildMusicianShellRoutes() {
  return [
    GoRoute(
      path: AppRoutes.musicians,
      pageBuilder: (context, state) =>
          _noTransitionPage(state, const MusiciansHubPage()),
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
      pageBuilder: (context, state) => _noTransitionPage(
        state,
        buildMusicianDetailRoute(context, state),
      ),
    ),
    GoRoute(
      path: AppRoutes.musicianDetailLegacyRoute,
      pageBuilder: (context, state) => _noTransitionPage(
        state,
        buildMusicianDetailRoute(context, state),
      ),
    ),
    GoRoute(
      path: AppRoutes.affinity,
      pageBuilder: (context, state) =>
          _noTransitionPage(state, const MatchingPage()),
    ),
    GoRoute(
      path: AppRoutes.matching,
      redirect: (context, state) => AppRoutes.affinity,
    ),
  ];
}
