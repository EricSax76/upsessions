import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/sm_avatar.dart';
import '../../../../l10n/app_localizations.dart';
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
              'Acciones rápidas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
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
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Hola, $titleName 👋',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
                      Text(
                        '¿Listo para conectar con otros músicos hoy?',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                SmAvatar(
                  radius: AppSpacing.xl,
                  imageUrl: viewModel.photoUrl,
                  initials: viewModel.initials,
                  backgroundColor: colorScheme.primaryContainer,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (isSplit)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: viewModel.upcomingRehearsals.length > 1
                        ? RehearsalsQuickView(
                            rehearsals: viewModel.upcomingRehearsals,
                          )
                        : HomeHeroNextRehearsalCard(
                            rehearsal: viewModel.nextRehearsal,
                          ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: actionsBlock),
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
        );
      },
    );
  }
}
