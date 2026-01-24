import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/sm_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import 'home_hero_view_model.dart';
import 'home_hero_widgets.dart';

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.appName.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs + AppSpacing.xs),
                  Text(
                    titleName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            SmAvatar(
              radius: AppSpacing.lg,
              imageUrl: viewModel.photoUrl,
              initials: viewModel.initials,
              backgroundColor: AppColors.primaryContainer,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md + AppSpacing.xs),
        HomeHeroNextRehearsalCard(rehearsal: viewModel.nextRehearsal),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Acciones rápidas',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const HomeHeroQuickActionsGrid(),
      ],
    );
  }
}
