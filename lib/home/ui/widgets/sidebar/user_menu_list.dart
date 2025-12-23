import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../features/contacts/application/liked_musicians_controller.dart';

class UserMenuList extends StatefulWidget {
  const UserMenuList({super.key});

  @override
  State<UserMenuList> createState() => _UserMenuListState();
}

class _UserMenuListState extends State<UserMenuList> {
  final List<_MenuItem> _items = const [
    _MenuItem(label: 'Mensajes', route: AppRoutes.messages),
    _MenuItem(label: 'Calendario', route: AppRoutes.calendar),
    _MenuItem(label: 'Contactos', route: AppRoutes.contacts),
    _MenuItem(label: 'Mis grupos', route: AppRoutes.rehearsals),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _items.length; i++)
          ListTile(
            selected: i == _selectedIndex,
            leading: const Icon(Icons.chevron_right),
            title: Text(
              _items[i].route == AppRoutes.contacts
                  ? 'Contactos ($contactsTotal)'
                  : _items[i].label,
            ),
            onTap: () => _handleTap(context, i),
          ),
        const SizedBox(height: 12),
        _ContactsPreview(controller: _likedController),
      ],
    );
  }
}

class _MenuItem {
  const _MenuItem({required this.label, this.route});

  final String label;
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
