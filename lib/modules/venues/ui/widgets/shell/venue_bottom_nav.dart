import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../../core/constants/app_routes.dart';

class VenueBottomNav extends StatelessWidget {
  const VenueBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.path;
    final isDashboard = location.startsWith(AppRoutes.venuesDashboard);
    final currentIndex = isDashboard ? 0 : 1;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == 0) {
          context.go(AppRoutes.venuesDashboard);
          return;
        }
        context.go(AppRoutes.venues);
      },
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront),
          label: localizations.venueBottomNavPanel,
        ),
        NavigationDestination(
          icon: Icon(Icons.travel_explore_outlined),
          selectedIcon: Icon(Icons.travel_explore),
          label: localizations.venueBottomNavExplore,
        ),
      ],
    );
  }
}
