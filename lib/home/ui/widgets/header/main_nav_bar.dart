import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';

class MainNavBar extends StatelessWidget implements PreferredSizeWidget {
  const MainNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final loc = AppLocalizations.of(context);
    final items = [
      _NavItem(
        label: loc.navMusicians,
        path: AppRoutes.musicians,
        icon: Icons.people_alt_outlined,
      ),
      _NavItem(
        label: loc.navAnnouncements,
        path: AppRoutes.announcements,
        icon: Icons.campaign_outlined,
      ),
      _NavItem(
        label: loc.navEvents,
        path: AppRoutes.events,
        icon: Icons.event_outlined,
      ),
      _NavItem(
        label: loc.navRehearsals,
        path: AppRoutes.rehearsals,
        icon: Icons.music_note_outlined,
      ),
    ];
    final location = GoRouterState.of(context).uri.path;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;
        final scheme = theme.colorScheme;
        final selectedBackground = scheme.primaryContainer;
        final selectedBorder = scheme.primary;

        Widget buildButton(
          _NavItem item, {
          required bool selected,
          EdgeInsetsGeometry? padding,
          bool scaleDownLabel = false,
        }) {
          final label = Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            textAlign: TextAlign.center,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          );
          return TextButton(
            onPressed: selected ? null : () => context.go(item.path),
            style: TextButton.styleFrom(
              foregroundColor:
                  selected ? scheme.primary : scheme.onSurfaceVariant,
              backgroundColor:
                  selected ? selectedBackground : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: selected ? selectedBorder : Colors.transparent,
                ),
              ),
              padding:
                  padding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
            ),
            child: scaleDownLabel
                ? FittedBox(fit: BoxFit.scaleDown, child: label)
                : label,
          );
        }

        Widget buildCompactButton(_NavItem item, {required bool selected}) {
          final labelStyle = textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
          return InkWell(
            onTap: selected ? null : () => context.go(item.path),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: selected ? selectedBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? selectedBorder : Colors.transparent,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 20,
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: labelStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ColoredBox(
          color: scheme.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(height: 1, color: scheme.outline),
              SizedBox(
                height: 60,
                child: isCompact
                    ? Row(
                        children: [
                          for (final item in items)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: buildCompactButton(
                                  item,
                                  selected: _isCurrent(location, item.path),
                                ),
                              ),
                            ),
                        ],
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return buildButton(
                            item,
                            selected: _isCurrent(location, item.path),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemCount: items.length,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  static bool _isCurrent(String location, String path) {
    if (location == path) {
      return true;
    }
    return location.startsWith('$path/');
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.path,
    required this.icon,
  });

  final String label;
  final String path;
  final IconData icon;
}
