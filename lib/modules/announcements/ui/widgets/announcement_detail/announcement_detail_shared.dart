import 'package:flutter/material.dart';
import 'package:upsessions/core/constants/app_spacing.dart';

class AnnouncementInfoPill extends StatelessWidget {
  const AnnouncementInfoPill({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final trimmed = label.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: scheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              trimmed,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnnouncementChipWrap extends StatelessWidget {
  const AnnouncementChipWrap({super.key, required this.values});

  final Iterable<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: values
          .where((value) => value.trim().isNotEmpty)
          .map(
            (value) => Chip(
              label: Text(value),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: scheme.surfaceContainerHighest,
              side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.65),
              ),
              labelStyle: theme.textTheme.labelMedium,
            ),
          )
          .toList(),
    );
  }
}

String formatAnnouncementLocation(String city, String province) {
  final trimmedCity = city.trim();
  final trimmedProvince = province.trim();
  if (trimmedCity.isEmpty) return trimmedProvince;
  if (trimmedProvince.isEmpty) return trimmedCity;
  if (trimmedCity.toLowerCase() == trimmedProvince.toLowerCase()) {
    return trimmedCity;
  }
  return '$trimmedCity, $trimmedProvince';
}
