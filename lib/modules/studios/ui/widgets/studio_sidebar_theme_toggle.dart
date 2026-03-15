import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/settings_tile.dart';

class StudioSidebarThemeToggle extends StatelessWidget {
  const StudioSidebarThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark =
            themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);
        final colorScheme = Theme.of(context).colorScheme;
        final loc = AppLocalizations.of(context);

        return SettingsTile(
          onTap: () => context.read<ThemeCubit>().toggleTheme(),
          icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          title: isDark
              ? loc.studioSidebarThemeLight
              : loc.studioSidebarThemeDark,
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
