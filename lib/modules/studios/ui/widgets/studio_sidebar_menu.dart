import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../auth/cubits/auth_cubit.dart';

class StudioSidebarMenu extends StatelessWidget {
  const StudioSidebarMenu({super.key});

  List<_MenuItem> _items(AppLocalizations loc) {
    return [
      _MenuItem(
        label: loc.studioSidebarMenuDashboard,
        icon: Icons.dashboard_outlined,
        route: AppRoutes.studiosDashboard,
      ),
      _MenuItem(
        label: loc.studioSidebarMenuBookings,
        icon: Icons.event_note_outlined,
        route: null,
      ),
      _MenuItem(
        label: loc.studioSidebarMenuRooms,
        icon: Icons.meeting_room_outlined,
        route: null,
      ),
      _MenuItem(
        label: loc.studioSidebarMenuProfile,
        icon: Icons.store_outlined,
        route: AppRoutes.studiosProfile,
      ),
    ];
  }

  void _handleTap(BuildContext context, _MenuItem item) {
    final route = item.route;
    if (route == null) return;

    final router = GoRouter.of(context);
    final scaffoldState = Scaffold.maybeOf(context);
    scaffoldState?.closeDrawer();
    router.go(route);
  }

  bool _isSelectedRoute(String currentPath, String route) {
    if (currentPath == route) {
      return true;
    }
    return currentPath.startsWith('$route/');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context);
    final items = _items(loc);
    final location = GoRouterState.of(context).uri.path;

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _StudioSidebarMenuTile(
              item: item,
              selected:
                  item.route != null && _isSelectedRoute(location, item.route!),
              onTap: () => _handleTap(context, item),
            ),
          ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        ListTile(
          leading: Icon(Icons.logout, color: colorScheme.error),
          title: Text(
            loc.studioSidebarLogout,
            style: TextStyle(color: colorScheme.error),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () {
            context.read<AuthCubit>().signOut();
            context.go(AppRoutes.studiosLogin);
          },
        ),
      ],
    );
  }
}

class _StudioSidebarMenuTile extends StatelessWidget {
  const _StudioSidebarMenuTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _MenuItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      selected: selected,
      leading: Icon(
        item.icon,
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      onTap: onTap,
    );
  }
}

class _MenuItem {
  const _MenuItem({required this.label, required this.icon, this.route});

  final String label;
  final IconData icon;
  final String? route;
}
