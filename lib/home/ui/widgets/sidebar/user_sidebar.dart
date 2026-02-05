import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/core/theme/theme_cubit.dart';
import 'package:upsessions/core/widgets/settings_tile.dart';
import 'package:upsessions/home/ui/widgets/sidebar/language_selector.dart';
import 'package:upsessions/home/ui/widgets/sidebar/user_sidebar_header.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import 'package:upsessions/modules/rehearsals/ui/widgets/rehearsals_sidebar_section.dart';
import 'user_menu_list.dart';

class UserSidebar extends StatelessWidget {
  const UserSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Column(
      children: [
        const UserSidebarHeader(),
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
                    loc.userSidebarTitle.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const UserMenuList(),
                const SizedBox(height: 32),
                const RehearsalsSidebarSection(),
                const SizedBox(height: 32),
                const _SidebarThemeToggle(),
                const SizedBox(height: 16),
                const LanguageSelector(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SidebarThemeToggle extends StatelessWidget {
  const _SidebarThemeToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark ||
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
