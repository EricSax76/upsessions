import 'package:flutter/material.dart';

import '../../application/settings_controller.dart';
import '../widgets/settings_list.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsController _controller = SettingsController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Configuración')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SettingsList(controller: _controller),
          ),
        );
      },
    );
  }
}
