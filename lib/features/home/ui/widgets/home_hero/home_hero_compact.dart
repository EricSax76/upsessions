import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:upsessions/core/constants/app_spacing.dart';
import 'package:upsessions/core/widgets/sm_avatar.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'home_hero_view_model.dart';
import 'home_hero_widgets.dart';
import 'rehearsals_quick_view.dart';

class HomeHeroCompact extends StatelessWidget {
  const HomeHeroCompact({super.key, required this.viewModel});

  final HomeHeroViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final titleName =
        viewModel.titleName.isEmpty ? loc.profile : viewModel.titleName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SmAvatar(
              radius: 26,
              imageUrl: viewModel.photoUrl,
              initials: viewModel.initials,
            )
                .animate()
                .fade(duration: 400.ms)
                .scale(begin: const Offset(0.88, 0.88), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, $titleName 👋',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loc.homeGreetingSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fade(duration: 500.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.05, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (viewModel.upcomingRehearsals.isNotEmpty)
          viewModel.upcomingRehearsals.length > 1
              ? RehearsalsQuickView(rehearsals: viewModel.upcomingRehearsals)
              : HomeHeroNextRehearsalCard(rehearsal: viewModel.nextRehearsal),
        const SizedBox(height: AppSpacing.xl),
        _ExploreDividerLabel(label: loc.homeExploreLabel),
        const SizedBox(height: AppSpacing.sm),
        const HomeHeroQuickActionsGrid(),
      ],
    );
  }
}

class _ExploreDividerLabel extends StatelessWidget {
  const _ExploreDividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
