import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:upsessions/modules/auth/models/profile_entity.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_stats_row.dart';
import '../widgets/profile/profile_empty_state.dart';

class ProfileOverviewPage extends StatelessWidget {
  const ProfileOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            onPressed: () => context.read<ProfileCubit>().refreshProfile(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar perfil',
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          switch (state.status) {
            case ProfileStatus.initial:
            case ProfileStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ProfileStatus.failure:
              return ProfileEmptyState(
                error: state.errorMessage,
                onRetry: () => context.read<ProfileCubit>().refreshProfile(),
              );
            case ProfileStatus.success:
              final profile = state.profile;
              if (profile == null) {
                return ProfileEmptyState(
                  onRetry: () => context.read<ProfileCubit>().refreshProfile(),
                );
              }
              return _ProfileContentView(profile: profile);
          }
        },
      ),
    );
  }
}

class _ProfileContentView extends StatelessWidget {
  const _ProfileContentView({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileHeader(profile: profile),
          const SizedBox(height: 16),
          Text(profile.bio),
          const SizedBox(height: 16),
          ProfileStatsRow(profile: profile),
        ],
      ),
    );
  }
}


