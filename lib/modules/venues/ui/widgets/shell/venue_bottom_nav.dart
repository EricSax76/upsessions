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

    int currentIndex = 0;
    if (location == AppRoutes.venuesDashboardNotifications) {
      currentIndex = 2;
    } else if (location == AppRoutes.venues) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.venuesDashboard)) {
      currentIndex = 0;
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.venuesDashboard);
          case 1:
            context.go(AppRoutes.venues);
          case 2:
            context.go(AppRoutes.venuesDashboardNotifications);
        }
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
        NavigationDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: 'Avisos',
        ),
      ],
    );
  }
}
