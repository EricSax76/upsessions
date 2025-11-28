import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/application/auth_cubit.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats_row.dart';

class ProfileOverviewPage extends StatelessWidget {
  const ProfileOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state.isLoading && state.lastAction == AuthAction.loadProfile;
        final error = state.lastAction == AuthAction.loadProfile ? state.errorMessage : null;
        final profile = state.profile;

        Widget body;
        if (isLoading) {
          body = const Center(child: CircularProgressIndicator());
        } else if (profile == null) {
          body = _ProfileEmptyState(
            error: error,
            onRetry: () => context.read<AuthCubit>().refreshProfile(),
          );
        } else {
          body = Padding(
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil'),
            actions: [
              IconButton(
                onPressed: () => context.read<AuthCubit>().refreshProfile(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualizar perfil',
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }
}

class _ProfileEmptyState extends StatelessWidget {
  const _ProfileEmptyState({required this.onRetry, this.error});

  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 64, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 12),
          Text(error ?? 'No pudimos cargar tu perfil.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
