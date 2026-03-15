import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_routes.dart';

class ManagerBottomNav extends StatelessWidget {
  const ManagerBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    if (location.startsWith(AppRoutes.eventManagerJamSessions)) {
      currentIndex = 2;
    } else if (location.startsWith(AppRoutes.eventManagerVenues)) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.eventManagerEvents)) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.eventManagerAgenda)) {
      currentIndex = 3;
    } else if (location.startsWith(AppRoutes.eventManagerHireMusicians) ||
        location.startsWith(AppRoutes.eventManagerGigOffers)) {
      currentIndex = 4;
    } else if (location.startsWith(AppRoutes.eventManagerNotifications)) {
      currentIndex = 5;
    }

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.eventManagerDashboard);
          case 1:
            context.go(AppRoutes.eventManagerEvents);
          case 2:
            context.go(AppRoutes.eventManagerJamSessions);
          case 3:
            context.go(AppRoutes.eventManagerAgenda);
          case 4:
            context.go(AppRoutes.eventManagerHireMusicians);
          case 5:
            context.go(AppRoutes.eventManagerNotifications);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_outlined),
          selectedIcon: Icon(Icons.event),
          label: 'Eventos',
        ),
        NavigationDestination(
          icon: Icon(Icons.music_note_outlined),
          selectedIcon: Icon(Icons.music_note),
          label: 'Jams',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Agenda',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_search_outlined),
          selectedIcon: Icon(Icons.person_search),
          label: 'Talento',
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
