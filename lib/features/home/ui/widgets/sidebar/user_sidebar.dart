import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/core/theme/theme_cubit.dart';
import 'package:upsessions/core/widgets/settings_tile.dart';
import 'package:upsessions/features/home/ui/widgets/sidebar/language_selector.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import 'package:upsessions/modules/groups/ui/widgets/rehearsals_sidebar_section.dart';
import 'user_menu_list.dart';
import 'package:upsessions/core/ui/shell/sidebar_cubit.dart';

class UserSidebar extends StatelessWidget {
  const UserSidebar({super.key, this.isCollapsed = false});

  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 16),
          child: Align(
            alignment: isCollapsed ? Alignment.center : Alignment.centerRight,
            child: IconButton(
              icon: Icon(isCollapsed ? Icons.menu : Icons.menu_open),
              onPressed: () => context.read<SidebarCubit>().toggle(),
              tooltip: isCollapsed ? 'Expandir menú' : 'Contraer menú',
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: isCollapsed ? 8 : 16,
            ),
            child: Column(
              crossAxisAlignment: isCollapsed
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                if (!isCollapsed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      loc.userSidebarTitle.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                UserMenuList(isCollapsed: isCollapsed),
                const SizedBox(height: 32),
                if (!isCollapsed) const RehearsalsSidebarSection(),
                const SizedBox(height: 32),
                _SidebarThemeToggle(isCollapsed: isCollapsed),
                const SizedBox(height: 16),
                if (!isCollapsed) const LanguageSelector(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SidebarThemeToggle extends StatelessWidget {
  const _SidebarThemeToggle({required this.isCollapsed});
  
  final bool isCollapsed;

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

        return isCollapsed
            ? IconButton(
                icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
              )
            : SettingsTile(
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
