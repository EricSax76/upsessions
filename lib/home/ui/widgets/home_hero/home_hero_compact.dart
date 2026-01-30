import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import 'home_hero_view_model.dart';
import 'home_hero_widgets.dart';
import 'rehearsals_quick_view.dart';

class HomeHeroCompact extends StatelessWidget {
  const HomeHeroCompact({super.key, required this.viewModel});

  final HomeHeroViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            'Dashboard',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (viewModel.upcomingRehearsals.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          viewModel.upcomingRehearsals.length > 1
              ? RehearsalsQuickView(rehearsals: viewModel.upcomingRehearsals)
              : HomeHeroNextRehearsalCard(rehearsal: viewModel.nextRehearsal),
        ],
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Acciones rápidas',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const HomeHeroQuickActionsGrid(),
      ],
    );
  }
}
