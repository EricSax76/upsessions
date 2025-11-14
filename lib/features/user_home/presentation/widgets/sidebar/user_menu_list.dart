import 'package:flutter/material.dart';

class UserMenuList extends StatefulWidget {
  const UserMenuList({super.key});

  @override
  State<UserMenuList> createState() => _UserMenuListState();
}

class _UserMenuListState extends State<UserMenuList> {
  final _items = const ['Panel', 'Mensajes', 'Calendario', 'Contactos'];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _items.length; i++)
          ListTile(
            selected: i == _selectedIndex,
            leading: const Icon(Icons.chevron_right),
            title: Text(_items[i]),
            onTap: () => setState(() => _selectedIndex = i),
          ),
      ],
    );
  }
}
