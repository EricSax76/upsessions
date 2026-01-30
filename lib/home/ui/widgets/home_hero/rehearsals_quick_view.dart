import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../modules/rehearsals/cubits/rehearsal_entity.dart';

class RehearsalsQuickView extends StatefulWidget {
  const RehearsalsQuickView({
    super.key,
    required this.rehearsals,
  });

  final List<RehearsalEntity> rehearsals;

  @override
  State<RehearsalsQuickView> createState() => _RehearsalsQuickViewState();
}

class _RehearsalsQuickViewState extends State<RehearsalsQuickView> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.rehearsals.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final firstRehearsal = widget.rehearsals.first;
    final remainingCount = widget.rehearsals.length - 1;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Main Highlighted Rehearsal (Always visible)
          InkWell(
            onTap: remainingCount > 0
                ? () => setState(() => _isExpanded = !_isExpanded)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
              child: Column(
                children: [
                   _RehearsalMainContent(rehearsal: firstRehearsal),
                   if (remainingCount > 0) ...[
                     const SizedBox(height: AppSpacing.md),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text(
                           _isExpanded 
                               ? 'Ocultar próximos ensayos' 
                               : 'Ver $remainingCount ensayos más reprogramados',
                           style: theme.textTheme.labelMedium?.copyWith(
                             color: colorScheme.primary,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                         const SizedBox(width: AppSpacing.xs),
                         Icon(
                           _isExpanded 
                              ? Icons.keyboard_arrow_up 
                              : Icons.keyboard_arrow_down,
                           size: 16,
                           color: colorScheme.primary,
                         ),
                       ],
                     )
                   ]
                ],
              ),
            ),
          ),

          // Collapsible List
          if (_isExpanded && remainingCount > 0)
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Column(
                children: widget.rehearsals.skip(1).map((rehearsal) {
                  return _RehearsalListItem(rehearsal: rehearsal);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _RehearsalMainContent extends StatelessWidget {
  const _RehearsalMainContent({required this.rehearsal});

  final RehearsalEntity rehearsal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    
    final dateLabel = DateFormat.MMMd(locale).format(rehearsal.startsAt);
    final timeLabel = DateFormat.Hm(locale).format(rehearsal.startsAt);
    final notes = rehearsal.notes.trim();
    final title = notes.isEmpty ? loc.homeNextRehearsalFallbackTitle : notes;
    final location = rehearsal.location.trim();

    return InkWell(
      onTap: () => context.push(
        AppRoutes.rehearsalDetail(
          groupId: rehearsal.groupId,
          rehearsalId: rehearsal.id,
        ),
      ),
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'PRÓXIMO ENSAYO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                 padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Text(
                  dateLabel.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 16, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                timeLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _RehearsalListItem extends StatelessWidget {
  const _RehearsalListItem({required this.rehearsal});

  final RehearsalEntity rehearsal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    
    final dayLabel = DateFormat.d(locale).format(rehearsal.startsAt);
    final monthLabel = DateFormat.MMM(locale).format(rehearsal.startsAt);
    final timeLabel = DateFormat.Hm(locale).format(rehearsal.startsAt);
    final notes = rehearsal.notes.trim();
    final title = notes.isEmpty ? loc.homeNextRehearsalFallbackTitle : notes;

    return InkWell(
      onTap: () => context.push(
        AppRoutes.rehearsalDetail(
          groupId: rehearsal.groupId,
          rehearsalId: rehearsal.id,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md + AppSpacing.xs,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  Text(
                    dayLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  Text(
                    monthLabel.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    timeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(width: AppSpacing.sm),
            // Icon(
            //   Icons.chevron_right,
            //   size: 20,
            //   color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            // ),
          ],
        ),
      ),
    );
  }
}
