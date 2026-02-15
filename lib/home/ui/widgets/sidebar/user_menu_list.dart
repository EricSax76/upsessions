// import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';

import '../../../../features/contacts/cubits/liked_musicians_cubit.dart';

// import '../../../../features/messaging/repositories/chat_repository.dart'; // Removed
// import '../../../../features/notifications/repositories/invite_notifications_repository.dart'; // Removed
import '../../../../features/notifications/cubits/notifications_status_cubit.dart';

class UserMenuList extends StatefulWidget {
  const UserMenuList({super.key});

  @override
  State<UserMenuList> createState() => _UserMenuListState();
}

class _UserMenuListState extends State<UserMenuList> {
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
      route: AppRoutes.matching,
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
    final contactsTotal = context.watch<LikedMusiciansCubit>().state.total;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final location = GoRouterState.of(context).uri.path;
    final width = MediaQuery.of(context).size.width;
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
        for (final item in visibleItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              selected:
                  item.route != null && _isSelectedRoute(location, item.route!),
              leading: Icon(
                item.icon,
                color:
                    (item.route != null &&
                        _isSelectedRoute(location, item.route!))
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              title: Text(
                item.route == AppRoutes.contacts
                    ? 'Contactos ($contactsTotal)'
                    : item.label,
                style: TextStyle(
                  fontWeight:
                      (item.route != null &&
                          _isSelectedRoute(location, item.route!))
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color:
                      (item.route != null &&
                          _isSelectedRoute(location, item.route!))
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
              selectedTileColor: colorScheme.primaryContainer.withValues(
                alpha: 0.3,
              ),
              onTap: () => _handleTap(context, item),
            ),
          ),
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
