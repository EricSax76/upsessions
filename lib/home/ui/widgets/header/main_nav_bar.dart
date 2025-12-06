import 'package:flutter/material.dart';

class MainNavBar extends StatelessWidget implements PreferredSizeWidget {
  const MainNavBar({super.key});

  static const List<String> sections = [
    'Inicio',
    'Músicos',
    'Anuncios',
    'Mensajes',
    'Eventos',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tabs = sections.map((section) => Tab(text: section)).toList();

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: 1, color: Theme.of(context).dividerColor),
          SizedBox(
            height: 56,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                labelColor: colorScheme.primary,

                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.symmetric(vertical: 10),
                overlayColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.pressed)
                      ? colorScheme.primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                indicator: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.32),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                tabs: tabs,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
