import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_routes.dart';

class MainNavBar extends StatelessWidget implements PreferredSizeWidget {
  const MainNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final items = [
      _NavItem(label: loc.navMusicians, path: AppRoutes.musicians),
      _NavItem(label: loc.navAnnouncements, path: AppRoutes.announcements),
      _NavItem(label: loc.navEvents, path: AppRoutes.events),
      _NavItem(label: loc.navRehearsals, path: AppRoutes.rehearsals),
    ];
    final colorScheme = Theme.of(context).colorScheme;
    final location = GoRouterState.of(context).uri.path;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520;

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
          );
          return TextButton(
            onPressed: selected ? null : () => context.go(item.path),
            style: TextButton.styleFrom(
              foregroundColor: selected
                  ? colorScheme.primary
                  : colorScheme.onSurface,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
              backgroundColor: selected
                  ? colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: selected
                      ? colorScheme.primary.withValues(alpha: 0.32)
                      : Colors.transparent,
                ),
              ),
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: scaleDownLabel
                ? FittedBox(fit: BoxFit.scaleDown, child: label)
                : label,
          );
        }

        return ColoredBox(
          color: colorScheme.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(height: 1, color: Theme.of(context).dividerColor),
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
                                child: buildButton(
                                  item,
                                  selected: _isCurrent(location, item.path),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 12,
                                  ),
                                  scaleDownLabel: true,
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
  const _NavItem({required this.label, required this.path});

  final String label;
  final String path;
}
