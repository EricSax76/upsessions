import 'package:flutter/material.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({
    super.key,
    required this.darkMode,
    required this.notifications,
    required this.onDarkModeChanged,
    required this.onNotificationsChanged,
  });

  final bool darkMode;
  final bool notifications;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Modo oscuro'),
          value: darkMode,
          onChanged: onDarkModeChanged,
        ),
        SwitchListTile(
          title: const Text('Notificaciones'),
          value: notifications,
          onChanged: onNotificationsChanged,
        ),
      ],
    );
  }
}
