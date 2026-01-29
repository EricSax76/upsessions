import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import 'home_hero_view_model.dart';
import 'home_hero_widgets.dart';

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
        if (viewModel.nextRehearsal != null) ...[
          const SizedBox(height: AppSpacing.lg),
          HomeHeroNextRehearsalCard(rehearsal: viewModel.nextRehearsal),
        ],
      ],
    );
  }
}
