import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../modules/rehearsals/models/rehearsal_entity.dart';

class HomeHeroNextRehearsalCard extends StatelessWidget {
  const HomeHeroNextRehearsalCard({super.key, required this.rehearsal});

  final RehearsalEntity? rehearsal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xs),
      elevation: 0,
      onTap: rehearsal == null
          ? null
          : () => context.push(
              AppRoutes.rehearsalDetail(
                groupId: rehearsal!.groupId,
                rehearsalId: rehearsal!.id,
              ),
            ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: rehearsal == null
          ? Text(
              loc.rehearsalsNoUpcoming,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : _HomeHeroNextRehearsalContent(rehearsal: rehearsal!),
    );
  }
}

class _HomeHeroNextRehearsalContent extends StatelessWidget {
  const _HomeHeroNextRehearsalContent({required this.rehearsal});

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              loc.homeNextRehearsalLabel.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.6,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
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
              const SizedBox(width: AppSpacing.xxs + AppSpacing.xs),
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
        Wrap(
          spacing: AppSpacing.xs + AppSpacing.xxs,
          runSpacing: AppSpacing.xs + AppSpacing.xxs,
          children: [
            _HomeHeroDateChip(label: dateLabel),
            _HomeHeroDateChip(label: timeLabel),
          ],
        ),
      ],
    );
  }
}

class _HomeHeroDateChip extends StatelessWidget {
  const _HomeHeroDateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class HomeHeroQuickActionsGrid extends StatelessWidget {
  const HomeHeroQuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.25,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _HomeHeroQuickActionTile(

          label: loc.navMusicians,
          imagePath: 'assets/images/home/quick_actions/quick_musicians.png',
          onTap: () => context.push(AppRoutes.musicians),
        ),
        _HomeHeroQuickActionTile(

          label: loc.navAnnouncements,
          imagePath: 'assets/images/home/quick_actions/quick_announcements.png',
          onTap: () => context.push(AppRoutes.announcements),
        ),
        _HomeHeroQuickActionTile(

          label: loc.navEvents,
          imagePath: 'assets/images/home/quick_actions/quick_events.png',
          onTap: () => context.push(AppRoutes.events),
        ),
        _HomeHeroQuickActionTile(

          label: loc.navRehearsals,
          imagePath: 'assets/images/home/quick_actions/quick_rehearsals.png',
          onTap: () => context.push(AppRoutes.rehearsals),
        ),
      ],
    );
  }
}

class _HomeHeroQuickActionTile extends StatelessWidget {
  const _HomeHeroQuickActionTile({

    required this.label,
    required this.imagePath,
    required this.onTap,
  });


  final String label;
  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      elevation: 0,
      onTap: onTap,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
