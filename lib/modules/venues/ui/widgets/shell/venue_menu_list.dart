import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../../core/constants/app_routes.dart';
import '../../../../auth/cubits/auth_cubit.dart';

class VenueMenuList extends StatelessWidget {
  const VenueMenuList({super.key, required this.isCollapsed});

  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final location = GoRouterState.of(context).uri.path;
    final menuItems = <_VenueMenuRouteItem>[
      _VenueMenuRouteItem(
        icon: Icons.storefront_outlined,
        activeIcon: Icons.storefront,
        label: localizations.venueMenuDashboard,
        route: AppRoutes.venuesDashboard,
      ),
      _VenueMenuRouteItem(
        icon: Icons.add_business_outlined,
        activeIcon: Icons.add_business,
        label: localizations.venueMenuNewVenue,
        route: AppRoutes.venuesDashboardVenueForm,
      ),
      _VenueMenuRouteItem(
        icon: Icons.travel_explore_outlined,
        activeIcon: Icons.travel_explore,
        label: localizations.venueMenuExploreVenues,
        route: AppRoutes.venues,
      ),
      _VenueMenuRouteItem(
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications,
        label: 'Notificaciones',
        route: AppRoutes.venuesDashboardNotifications,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in menuItems.take(2))
            _buildItem(
              context,
              icon: item.icon,
              activeIcon: item.activeIcon,
              label: item.label,
              route: item.route,
              currentLocation: location,
            ),
          const Divider(height: 32),
          _buildItem(
            context,
            icon: menuItems[2].icon,
            activeIcon: menuItems[2].activeIcon,
            label: menuItems[2].label,
            route: menuItems[2].route,
            currentLocation: location,
          ),
          const Divider(height: 32),
          _buildItem(
            context,
            icon: menuItems[3].icon,
            activeIcon: menuItems[3].activeIcon,
            label: menuItems[3].label,
            route: menuItems[3].route,
            currentLocation: location,
          ),
          const Divider(height: 32),
          _buildActionItem(
            context,
            icon: Icons.logout,
            label: localizations.venueMenuLogout,
            onTap: () {
              context.read<AuthCubit>().signOut();
            },
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final contentColor = color ?? colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            onTap();
            if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(icon, color: contentColor, size: 24),
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(label, style: TextStyle(color: contentColor)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required String currentLocation,
  }) {
    final isActive = _isActiveRoute(currentLocation, route);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isActive ? colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (!isActive) {
              context.go(route);
            } else if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isActive
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isActiveRoute(String currentLocation, String route) {
    if (route == AppRoutes.venuesDashboard) {
      return currentLocation == AppRoutes.venuesDashboard;
    }
    if (route == AppRoutes.venuesDashboardVenueForm) {
      return currentLocation == AppRoutes.venuesDashboardVenueForm ||
          (currentLocation.startsWith('${AppRoutes.venuesDashboard}/') &&
              currentLocation.endsWith('/edit'));
    }
    if (route == AppRoutes.venues) {
      return currentLocation == AppRoutes.venues;
    }
    if (route == AppRoutes.venuesDashboardNotifications) {
      return currentLocation == AppRoutes.venuesDashboardNotifications;
    }
    return currentLocation.startsWith(route);
  }
}

class _VenueMenuRouteItem {
  const _VenueMenuRouteItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}
