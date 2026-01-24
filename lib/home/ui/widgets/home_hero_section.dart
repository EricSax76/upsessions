import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../modules/auth/cubits/auth_cubit.dart';
import '../../../modules/rehearsals/cubits/rehearsal_entity.dart';
import 'home_hero/home_hero_layout.dart';
import 'home_hero/home_hero_view_model.dart';

class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    super.key,
    this.isCompact = false,
    this.nextRehearsal,
  });

  final bool isCompact;
  final RehearsalEntity? nextRehearsal;

  @override
  Widget build(BuildContext context) {
    const heroPadding = AppSpacing.xl + AppSpacing.xs + AppSpacing.xs;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final viewModel = HomeHeroViewModel(
          displayName: state.user?.displayName ?? '',
          photoUrl: state.user?.photoUrl,
          nextRehearsal: nextRehearsal,
        );

        if (isCompact) {
          return HomeHeroLayout(
            isCompact: true,
            viewModel: viewModel,
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(heroPadding),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryContainer, AppColors.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.xl),
          ),
          child: HomeHeroLayout(
            isCompact: false,
            viewModel: viewModel,
          ),
        );
      },
    );
  }
}
