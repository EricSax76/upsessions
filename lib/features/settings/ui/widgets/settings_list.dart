import 'package:flutter/material.dart';

import '../../controllers/settings_controller.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Modo oscuro'),
          value: controller.darkMode,
          onChanged: controller.toggleDarkMode,
        ),
        SwitchListTile(
          title: const Text('Notificaciones'),
          value: controller.notifications,
          onChanged: controller.toggleNotifications,
        ),
      ],
    );
  }
}
