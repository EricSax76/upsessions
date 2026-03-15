import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import 'studio_sidebar_header.dart';
import 'studio_sidebar_menu.dart';
import 'studio_sidebar_theme_toggle.dart';

class StudioSidebar extends StatelessWidget {
  const StudioSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        const StudioSidebarHeader(),
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
                    loc.studioSidebarManagementTitle,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const StudioSidebarMenu(),
                const SizedBox(height: 32),
                const StudioSidebarThemeToggle(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
