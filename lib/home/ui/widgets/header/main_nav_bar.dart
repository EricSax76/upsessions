import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';

class MainNavBar extends StatelessWidget implements PreferredSizeWidget {
  const MainNavBar({super.key});

  static const _items = [
    _NavItem(label: 'Músicos', path: AppRoutes.musicians),
    _NavItem(label: 'Anuncios', path: AppRoutes.announcements),
    _NavItem(label: 'Eventos', path: AppRoutes.events),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final location = GoRouterState.of(context).uri.path;

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, color: Theme.of(context).dividerColor),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final item = _items[index];
                final selected = _isCurrent(location, item.path);
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(item.label),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: _items.length,
            ),
          ),
        ],
      ),
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
