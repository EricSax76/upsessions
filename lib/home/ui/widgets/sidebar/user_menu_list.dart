import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../features/contacts/controllers/liked_musicians_controller.dart';
import '../../../../features/messaging/repositories/chat_repository.dart';
import '../../../../features/notifications/repositories/invite_notifications_repository.dart';

class UserMenuList extends StatefulWidget {
  const UserMenuList({super.key});

  @override
  State<UserMenuList> createState() => _UserMenuListState();
}

class _UserMenuListState extends State<UserMenuList> {
  final List<_MenuItem> _items = const [
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
  late final LikedMusiciansController _likedController;

  @override
  void initState() {
    super.initState();
    _likedController = locate<LikedMusiciansController>()
      ..addListener(_onContactsChanged);
  }

  void _onContactsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _likedController.removeListener(_onContactsChanged);
    super.dispose();
  }

  void _handleTap(BuildContext context, int index) {
    final item = _items[index];
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
    final contactsTotal = _likedController.total;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final location = GoRouterState.of(context).uri.path;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              selected:
                  _items[i].route != null &&
                  _isSelectedRoute(location, _items[i].route!),
              leading: Icon(
                _items[i].icon,
                color:
                    (_items[i].route != null &&
                        _isSelectedRoute(location, _items[i].route!))
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              title: Text(
                _items[i].route == AppRoutes.contacts
                    ? 'Contactos ($contactsTotal)'
                    : _items[i].label,
                style: TextStyle(
                  fontWeight:
                      (_items[i].route != null &&
                          _isSelectedRoute(location, _items[i].route!))
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color:
                      (_items[i].route != null &&
                          _isSelectedRoute(location, _items[i].route!))
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
              trailing: _items[i].route == AppRoutes.notifications
                  ? const _NotificationsMenuBadge()
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selectedTileColor: colorScheme.primaryContainer.withValues(
                alpha: 0.3,
              ),
              onTap: () => _handleTap(context, i),
            ),
          ),
        const SizedBox(height: 12),
        _ContactsPreview(controller: _likedController),
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

class _ContactsPreview extends StatelessWidget {
  const _ContactsPreview({required this.controller});

  final LikedMusiciansController controller;

  @override
  Widget build(BuildContext context) {
    final contacts = controller.contacts;
    if (contacts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'Guarda músicos con el corazón para tener accesos rápidos aquí.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: contacts
            .map(
              (musician) => InputChip(
                avatar: const Icon(Icons.favorite, size: 16),
                label: Text(musician.name),
                onPressed: () => GoRouter.of(context).go(AppRoutes.contacts),
                onDeleted: () => controller.remove(musician.id),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _NotificationsMenuBadge extends StatefulWidget {
  const _NotificationsMenuBadge();

  @override
  State<_NotificationsMenuBadge> createState() =>
      _NotificationsMenuBadgeState();
}

class _NotificationsMenuBadgeState extends State<_NotificationsMenuBadge> {
  late final ChatRepository _chatRepository;
  late final InviteNotificationsRepository _invitesRepository;
  final _totalUnreadController = StreamController<int>();
  final _subscriptions = <StreamSubscription>[];

  int _unreadChats = 0;
  int _unreadInvites = 0;

  @override
  void initState() {
    super.initState();
    _chatRepository = locate<ChatRepository>();
    _invitesRepository = locate<InviteNotificationsRepository>();

    _subscriptions.add(
      _chatRepository.watchUnreadTotal().listen((count) {
        _unreadChats = count;
        _emitTotal();
      }),
    );

    _subscriptions.add(
      _invitesRepository.watchMyInvites().listen((invites) {
        _unreadInvites = invites.where((i) => !i.read).length;
        _emitTotal();
      }),
    );
  }

  void _emitTotal() {
    if (!_totalUnreadController.isClosed) {
      _totalUnreadController.add(_unreadChats + _unreadInvites);
    }
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _totalUnreadController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _totalUnreadController.stream,
      initialData: 0,
      builder: (context, snapshot) {
        final unreadTotal = snapshot.data ?? 0;
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
