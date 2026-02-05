import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../features/contacts/controllers/liked_musicians_controller.dart';

class UserMenuList extends StatefulWidget {
  const UserMenuList({super.key});

  @override
  State<UserMenuList> createState() => _UserMenuListState();
}

class _UserMenuListState extends State<UserMenuList> {
  final List<_MenuItem> _items = const [
    _MenuItem(label: 'Inicio', icon: Icons.home_outlined, route: AppRoutes.userHome),
    _MenuItem(label: 'Músicos', icon: Icons.person_search_outlined, route: AppRoutes.musicians),
    _MenuItem(label: 'Anuncios', icon: Icons.campaign_outlined, route: AppRoutes.announcements),
    _MenuItem(label: 'Eventos', icon: Icons.event_outlined, route: AppRoutes.events),
    _MenuItem(label: 'Mensajes', icon: Icons.mail_outline, route: AppRoutes.messages),
    _MenuItem(label: 'Calendario', icon: Icons.calendar_month_outlined, route: AppRoutes.calendar),
    _MenuItem(label: 'Contactos', icon: Icons.people_outline, route: AppRoutes.contacts),
    _MenuItem(label: 'Mis grupos', icon: Icons.group_outlined, route: AppRoutes.rehearsals),
    _MenuItem(label: 'Salas de Ensayo', icon: Icons.music_note_outlined, route: AppRoutes.studios),
    _MenuItem(label: 'Mis Reservas', icon: Icons.bookmark_added_outlined, route: AppRoutes.myBookings),
  ];
  late final LikedMusiciansController _likedController;
  int _selectedIndex = 0;

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
    setState(() => _selectedIndex = index);

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

  @override
  Widget build(BuildContext context) {
    final contactsTotal = _likedController.total;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              selected: i == _selectedIndex,
              leading: Icon(
                _items[i].icon,
                color: i == _selectedIndex ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              title: Text(
                _items[i].route == AppRoutes.contacts
                    ? 'Contactos ($contactsTotal)'
                    : _items[i].label,
                style: TextStyle(
                  fontWeight: i == _selectedIndex ? FontWeight.bold : FontWeight.normal,
                  color: i == _selectedIndex ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
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
