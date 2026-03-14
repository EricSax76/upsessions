import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:upsessions/core/constants/app_routes.dart';

import 'package:upsessions/modules/contacts/cubits/liked_musicians_cubit.dart';
import 'package:upsessions/modules/notifications/cubits/notifications_status_cubit.dart';

class UserMenuList extends StatelessWidget {
  const UserMenuList({super.key, this.isCollapsed = false});

  final bool isCollapsed;
  static const List<_MenuItem> _allNavItems = [
    _MenuItem(
      label: 'Inicio',
      icon: Icons.home_outlined,
      route: AppRoutes.userHome,
    ),
    _MenuItem(
      label: 'Músicos',
      icon: Icons.person_search_outlined,
      route: AppRoutes.musicians,
    ),
    _MenuItem(
      label: 'Afinidad',
      icon: Icons.hub_outlined,
      route: AppRoutes.affinity,
    ),
    _MenuItem(
      label: 'Anuncios',
      icon: Icons.campaign_outlined,
      route: AppRoutes.announcements,
    ),
    _MenuItem(
      label: 'Eventos',
      icon: Icons.event_outlined,
      route: AppRoutes.events,
    ),
    _MenuItem(
      label: 'Jam Sessions',
      icon: Icons.music_note_outlined,
      route: AppRoutes.jamSessions,
    ),
    _MenuItem(
      label: 'Mensajes',
      icon: Icons.mail_outline,
      route: AppRoutes.messages,
    ),
    _MenuItem(
      label: 'Notificaciones',
      icon: Icons.notifications_outlined,
      route: AppRoutes.notifications,
    ),
    _MenuItem(
      label: 'Calendario',
      icon: Icons.calendar_month_outlined,
      route: AppRoutes.calendar,
    ),
    _MenuItem(
      label: 'Contactos',
      icon: Icons.people_outline,
      route: AppRoutes.contacts,
    ),
    _MenuItem(
      label: 'Mis grupos',
      icon: Icons.group_outlined,
      route: AppRoutes.rehearsals,
    ),
    _MenuItem(
      label: 'Salas de Ensayo',
      icon: Icons.music_note_outlined,
      route: AppRoutes.studios,
    ),
    _MenuItem(
      label: 'Gestión de Sala',
      icon: Icons.storefront_outlined,
      route: AppRoutes.studiosDashboard,
    ),
    _MenuItem(
      label: 'Mis Reservas',
      icon: Icons.bookmark_added_outlined,
      route: AppRoutes.myBookings,
    ),
  ];

  void _handleTap(BuildContext context, _MenuItem item) {
    final route = item.route;
    if (route == null) {
      return;
    }

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final location = GoRouterState.of(context).uri.path;
    final width = MediaQuery.sizeOf(context).width;
    final isWideLayout = kIsWeb ? width >= 700 : width >= 1200;

    final visibleItems = isWideLayout
        ? _allNavItems
        : _allNavItems.where((item) {
            return item.route != AppRoutes.userHome &&
                item.route != AppRoutes.messages &&
                item.route != AppRoutes.calendar;
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in visibleItems) ...[
          Builder(
            builder: (context) {
              final isSelected =
                  item.route != null && _isSelectedRoute(location, item.route!);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: isCollapsed
                    ? InkWell(
                        onTap: () => _handleTap(context, item),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primaryContainer.withValues(
                                    alpha: 0.3,
                                  )
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              item.icon,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : ListTile(
                        selected: isSelected,
                        leading: Icon(
                          item.icon,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        title: item.route == AppRoutes.contacts
                            ? _ContactsMenuTitle(isSelected: isSelected)
                            : Text(
                                item.label,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                        trailing: item.route == AppRoutes.notifications
                            ? const _NotificationsMenuBadge()
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        selectedTileColor: colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                        onTap: () => _handleTap(context, item),
                      ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _MenuItem {
  const _MenuItem({required this.label, required this.icon, this.route});

  final String label;
  final IconData icon;
  final String? route;
}

class _ContactsMenuTitle extends StatelessWidget {
  const _ContactsMenuTitle({required this.isSelected});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final contactsTotal = context.select(
      (LikedMusiciansCubit cubit) => cubit.state.total,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      'Contactos ($contactsTotal)',
      style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
      ),
    );
  }
}

class _NotificationsMenuBadge extends StatelessWidget {
  const _NotificationsMenuBadge();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsStatusCubit, int>(
      builder: (context, unreadTotal) {
        if (unreadTotal <= 0) return const SizedBox.shrink();
        final label = unreadTotal > 99 ? '99+' : unreadTotal.toString();
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onError,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        );
      },
    );
  }
}
