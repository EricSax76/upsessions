import 'package:flutter/material.dart';

class HeroStatsSection extends StatelessWidget {
  const HeroStatsSection({
    super.key,
    required this.title,
    this.description,
    required this.gradientColors,
    required this.stats,
    this.action,
    this.textColor,
  });

  final String title;
  final String? description;
  final List<Color> gradientColors;
  final List<HeroStatItem> stats;
  final Widget? action;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final onSurface = textColor ?? colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    if (i > 0)
                      Container(
                        height: 16,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: onSurface.withValues(alpha: 0.2),
                      ),
                    _StatItemWidget(
                      item: stats[i],
                      colorScheme: colorScheme,
                      textColor: onSurface,
                    ),
                  ],
                ],
              ),
              ?action,
            ],
          ),
        ],
      ),
    );
  }
}

class HeroStatItem {
  const HeroStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

class _StatItemWidget extends StatelessWidget {
  const _StatItemWidget({
    required this.item,
    required this.colorScheme,
    required this.textColor,
  });

  final HeroStatItem item;
  final ColorScheme colorScheme;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              item.value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
