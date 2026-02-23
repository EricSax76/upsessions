import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:upsessions/core/constants/app_spacing.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'home_hero_view_model.dart';
import 'home_hero_widgets.dart';
import 'rehearsals_quick_view.dart';

class HomeHeroExpanded extends StatelessWidget {
  const HomeHeroExpanded({super.key, required this.viewModel});

  final HomeHeroViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    final titleName =
        viewModel.titleName.isEmpty ? loc.profile : viewModel.titleName;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSplit = constraints.maxWidth >= 900;
        final actionsBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EXPLORAR',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const HomeHeroQuickActionsGrid(),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $titleName 👋',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (isSplit)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: viewModel.upcomingRehearsals.length > 1
                        ? RehearsalsQuickView(
                            rehearsals: viewModel.upcomingRehearsals,
                          )
                        : HomeHeroNextRehearsalCard(
                            rehearsal: viewModel.nextRehearsal,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    flex: 5,
                    child: actionsBlock,
                  ),
                ],
              )
            else ...[
              viewModel.upcomingRehearsals.length > 1
                  ? RehearsalsQuickView(
                      rehearsals: viewModel.upcomingRehearsals,
                    )
                  : HomeHeroNextRehearsalCard(rehearsal: viewModel.nextRehearsal),
              const SizedBox(height: AppSpacing.lg),
              actionsBlock,
            ],
          ],
        )
            .animate()
            .fade(duration: 500.ms, curve: Curves.easeOut)
            .slideY(
              begin: 0.05,
              end: 0,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}
