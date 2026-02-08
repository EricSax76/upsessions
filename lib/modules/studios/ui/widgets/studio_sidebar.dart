import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/theme/theme_cubit.dart';
import 'package:upsessions/core/widgets/settings_tile.dart';
import 'package:upsessions/core/widgets/sm_avatar.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import '../../../../modules/auth/cubits/auth_cubit.dart';
import '../../../../modules/studios/cubits/studios_cubit.dart';
import '../../../../modules/studios/cubits/studios_state.dart';

class StudioSidebar extends StatelessWidget {
  const StudioSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        const _StudioSidebarHeader(),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'GESTIÓN DE ESTUDIO',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const _StudioMenuList(),
                const SizedBox(height: 32),
                const _SidebarThemeToggle(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StudioSidebarHeader extends StatelessWidget {
  const _StudioSidebarHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<StudiosCubit, StudiosState>(
      builder: (context, state) {
        final studio = state.myStudio;

        return Container(
          padding: const EdgeInsets.all(20),
          color: colorScheme.surfaceContainerLow,
          child: Row(
            children: [
              SmAvatar(
                radius: 24,
                imageUrl: studio?.logoUrl,
                fallbackIcon: Icons.store,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studio?.name ?? 'Mi Estudio',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sesión de Studio',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StudioMenuList extends StatelessWidget {
  const _StudioMenuList();

  static const List<_MenuItem> _items = [
    _MenuItem(
      label: 'Panel',
      icon: Icons.dashboard_outlined,
      route: AppRoutes.studiosDashboard,
    ),
    _MenuItem(
      label: 'Mis Reservas',
      icon: Icons.event_note_outlined,
      route: null,
    ), // Tab in dashboard
    _MenuItem(
      label: 'Mis Salas',
      icon: Icons.meeting_room_outlined,
      route: null,
    ), // Tab in dashboard
    _MenuItem(
      label: 'Perfil del Estudio',
      icon: Icons.store_outlined,
      route: '/studios/profile',
    ),
  ];

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final location = GoRouterState.of(context).uri.path;

    return Column(
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
                _items[i].label,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              selectedTileColor: colorScheme.primaryContainer.withValues(
                alpha: 0.3,
              ),
              onTap: () => _handleTap(context, i),
            ),
          ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        // Logout
        ListTile(
          leading: Icon(Icons.logout, color: colorScheme.error),
          title: Text(
            'Cerrar Sesión',
            style: TextStyle(color: colorScheme.error),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () {
            context.read<AuthCubit>().signOut();
            context.go(AppRoutes.studiosLogin);
          },
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

class _SidebarThemeToggle extends StatelessWidget {
  const _SidebarThemeToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark =
            themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return SettingsTile(
          onTap: () {
            context.read<ThemeCubit>().toggleTheme();
          },
          icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          title: isDark ? 'Modo claro' : 'Modo oscuro',
          trailing: Switch(
            value: isDark,
            onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
            activeThumbColor: colorScheme.primary,
          ),
        );
      },
    );
  }
}
