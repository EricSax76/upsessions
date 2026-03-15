import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../features/settings/ui/widgets/account_settings/settings_section_title.dart';
import '../../../notifications/cubits/notification_preferences_cubit.dart';
import '../../../notifications/models/notification_scenario.dart';
import '../../../notifications/repositories/notification_preferences_repository.dart';
import '../../../notifications/ui/widgets/notification_preferences_section.dart';
import '../../cubits/event_manager_auth_cubit.dart';
import '../../cubits/event_manager_auth_state.dart';

class ManagerSettingsPage extends StatelessWidget {
  const ManagerSettingsPage({super.key});

  bool _isVenueAudience(List<String> specialties) {
    final normalized = specialties
        .map((entry) => entry.trim().toLowerCase())
        .where((entry) => entry.isNotEmpty)
        .toList();
    return normalized.length == 1 && normalized.first == 'venues';
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text(
            '¿Seguro que quieres cerrar tu sesión de manager?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) return;
    await context.read<EventManagerAuthCubit>().logout();
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: iconColor ?? colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationPreferencesCubit(
        repository: locate<NotificationPreferencesRepository>(),
      ),
      child: BlocBuilder<EventManagerAuthCubit, EventManagerAuthState>(
        builder: (context, authState) {
          final manager = authState.manager;
          final notificationsAudience =
              manager != null && _isVenueAudience(manager.specialties)
              ? NotificationAudience.venue
              : NotificationAudience.eventManager;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Ajustes',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestiona tu cuenta y accesos rápidos del panel manager.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      if (manager != null)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.store_outlined),
                            title: Text(manager.name),
                            subtitle: Text(
                              manager.contactEmail.isEmpty
                                  ? 'Cuenta de manager'
                                  : manager.contactEmail,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Card(
                        child: Column(
                          children: [
                            _settingsTile(
                              context,
                              icon: Icons.person_outline,
                              title: 'Perfil',
                              subtitle:
                                  'Editar nombre, foto y datos de contacto',
                              onTap: () =>
                                  context.push(AppRoutes.eventManagerProfile),
                            ),
                            const Divider(height: 1),
                            _settingsTile(
                              context,
                              icon: Icons.event_outlined,
                              title: 'Mis eventos',
                              subtitle: 'Revisar y gestionar tu calendario',
                              onTap: () =>
                                  context.go(AppRoutes.eventManagerEvents),
                            ),
                            const Divider(height: 1),
                            _settingsTile(
                              context,
                              icon: Icons.description_outlined,
                              title: 'Términos y privacidad',
                              subtitle:
                                  'Consultar términos, privacidad y cookies',
                              onTap: () => context.push(AppRoutes.legalPrivacy),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const SettingsSectionTitle(text: 'Notificaciones'),
                      const SizedBox(height: 12),
                      NotificationPreferencesSection(
                        audience: notificationsAudience,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: _settingsTile(
                          context,
                          icon: Icons.logout,
                          iconColor: Theme.of(context).colorScheme.error,
                          title: 'Cerrar sesión',
                          subtitle: 'Salir de la cuenta actual',
                          onTap: () => _confirmLogout(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
