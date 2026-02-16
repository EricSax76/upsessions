import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/settings_cubit.dart';
import '../../cubits/settings_state.dart';
import '../widgets/settings_list.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingsCubit(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Configuración',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return SettingsList(
                      darkMode: state.darkMode,
                      notifications: state.notifications,
                      onDarkModeChanged:
                          context.read<SettingsCubit>().toggleDarkMode,
                      onNotificationsChanged:
                          context.read<SettingsCubit>().toggleNotifications,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
