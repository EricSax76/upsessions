import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_routes.dart';

class ManagerMenuList extends StatelessWidget {
  const ManagerMenuList({super.key, this.isCollapsed = false});

  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItem(
            context,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Dashboard',
            route: AppRoutes.eventManagerDashboard,
            currentLocation: location,
          ),
          _buildItem(
            context,
            icon: Icons.event_outlined,
            activeIcon: Icons.event,
            label: 'Mis Eventos',
            route: AppRoutes.eventManagerEvents,
            currentLocation: location,
          ),
          _buildItem(
            context,
            icon: Icons.music_note_outlined,
            activeIcon: Icons.music_note,
            label: 'Jam Sessions',
            route: AppRoutes.eventManagerJamSessions,
            currentLocation: location,
          ),
          _buildItem(
            context,
            icon: Icons.calendar_month_outlined,
            activeIcon: Icons.calendar_month,
            label: 'Agenda',
            route: AppRoutes.eventManagerAgenda,
            currentLocation: location,
          ),
          const Divider(height: 32),
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'CONTRATACIÓN',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          _buildItem(
            context,
            icon: Icons.person_search_outlined,
            activeIcon: Icons.person_search,
            label: 'Contratar Músicos',
            route: AppRoutes.eventManagerHireMusicians,
            currentLocation: location,
          ),
          _buildItem(
            context,
            icon: Icons.work_outline,
            activeIcon: Icons.work,
            label: 'Ofertas de Gig',
            route: AppRoutes.eventManagerGigOffers,
            currentLocation: location,
          ),
          const Divider(height: 32),
          _buildItem(
            context,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Perfil',
            route: AppRoutes.eventManagerProfile,
            currentLocation: location,
          ),
          _buildItem(
            context,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Ajustes',
            route: AppRoutes.eventManagerSettings,
            currentLocation: location,
          ),
        ],
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
    final isActive = currentLocation.startsWith(route);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color:
                            isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
}
