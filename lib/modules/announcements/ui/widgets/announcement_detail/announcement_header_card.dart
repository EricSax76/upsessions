import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:upsessions/core/constants/app_spacing.dart';
import 'package:upsessions/core/widgets/app_card.dart';
import 'package:upsessions/core/widgets/date_badge.dart';

import '../../../models/announcement_entity.dart';
import 'announcement_detail_shared.dart';

class AnnouncementHeaderCard extends StatelessWidget {
  const AnnouncementHeaderCard({super.key, required this.announcement});

  final AnnouncementEntity announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = DateFormat.MMM(locale)
        .format(announcement.publishedAt)
        .toUpperCase();
    final dayLabel = DateFormat.d(locale).format(announcement.publishedAt);
    final author = announcement.author.trim();
    final location = formatAnnouncementLocation(
      announcement.city,
      announcement.province,
    );
    final instrument = announcement.instrument.trim();

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSpacing.lg),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.campaign_outlined,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (author.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        author,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        location,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              DateBadge(month: monthLabel, day: dayLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (location.isNotEmpty)
                AnnouncementInfoPill(
                  icon: Icons.place_outlined,
                  label: location,
                ),
              if (instrument.isNotEmpty)
                AnnouncementInfoPill(
                  icon: Icons.music_note_outlined,
                  label: instrument,
                ),
            ],
          ),
          if (announcement.styles.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            AnnouncementChipWrap(values: announcement.styles),
          ],
        ],
      ),
    );
  }
}
