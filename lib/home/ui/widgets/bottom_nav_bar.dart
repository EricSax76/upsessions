import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';

class UserBottomNavBar extends StatelessWidget {
  const UserBottomNavBar({super.key});

  static const _navItems = [
    _BottomNavItem(
      label: 'Inicio',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: AppRoutes.userHome,
    ),
    _BottomNavItem(
      label: 'Mensajes',
      icon: Icons.mail_outline,
      activeIcon: Icons.mail,
      route: AppRoutes.messages,
    ),
    _BottomNavItem(
      label: 'Calendario',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      route: AppRoutes.calendar,
    ),
    _BottomNavItem(
      label: 'Menú',
      icon: Icons.menu,
      activeIcon: Icons.menu,
      route: null, // Special case for Menu
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final location = GoRouterState.of(context).uri.path;

    // Calculate current index
    int currentIndex = 0;
    // We default to 0 (Home). If we are in Messages or Calendar, update index.
    // If we are in any other route (like Musicians, Profile, etc), we might want 
    // to show "Menu" generally or just not highlight anything specific, or keep Home?
    //
    // For this specific requirement:
    // - Home -> 0
    // - Messages -> 1
    // - Calendar -> 2
    // - Menu -> 3 (Visual cue that we are "elsewhere" or just to open drawer)
    
    // Logic:
    // If route matches exactly or starts with (for nested routes)
    if (location.startsWith(AppRoutes.messages)) {
      currentIndex = 1;
    } else if (location.startsWith(AppRoutes.calendar)) {
      currentIndex = 2;
    } else if (location == AppRoutes.userHome) {
      currentIndex = 0;
    } else {
      // If we are deep in "Musicians", "Profile", etc., we are technically "in the Menu" area 
      // regarding likely navigation, OR we treat Home as the default active.
      // However, BottomNavBar usually requires a valid index selection.
      // Let's see: if we are in "Musicians", we came from sidebar (Menu). 
      // If we act like the Drawer is the "Menu" route, then index 3 makes sense for "Other" pages.
      currentIndex = 3;
    }
    
    // Exception: If we are effectively on "Home" but logic put us in 3?
    // No, matching logic handles it.

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: _navItems.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.activeIcon),
          label: item.label,
        );
      }).toList(),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    final item = _navItems[index];

    if (item.route == null) {
      // Open Drawer
      Scaffold.of(context).openDrawer();
    } else {
      context.go(item.route!);
    }
  }
}

class _BottomNavItem {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.route,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String? route;
}
