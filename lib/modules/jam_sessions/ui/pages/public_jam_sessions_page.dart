import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../cubits/public_jam_sessions_cubit.dart';
import '../../cubits/public_jam_sessions_state.dart';
import '../../models/jam_session_entity.dart';
import '../widgets/public_jam_session_card.dart';

class PublicJamSessionsPage extends StatelessWidget {
  const PublicJamSessionsPage({super.key});

  Future<void> _handleJoin(
    BuildContext context,
    JamSessionEntity session,
  ) async {
    final outcome = await context.read<PublicJamSessionsCubit>().joinSession(
      session,
    );
    if (!context.mounted) return;

    switch (outcome.type) {
      case JoinJamOutcomeType.success:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Te has apuntado a la jam session.')),
        );
        break;
      case JoinJamOutcomeType.requiresLogin:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Necesitas iniciar sesión para apuntarte.'),
          ),
        );
        context.go(AppRoutes.login);
        break;
      case JoinJamOutcomeType.alreadyJoined:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya estás apuntado en esta sesión.')),
        );
        break;
      case JoinJamOutcomeType.full:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La sesión ya está completa.')),
        );
        break;
      case JoinJamOutcomeType.failure:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo completar: ${outcome.message ?? ''}'),
          ),
        );
        break;
      case JoinJamOutcomeType.busy:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicJamSessionsCubit, PublicJamSessionsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Jam Sessions públicas',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar',
                    onPressed: state.isLoading
                        ? null
                        : () => context
                              .read<PublicJamSessionsCubit>()
                              .loadSessions(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Descubre sesiones abiertas y apúntate como asistente.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, PublicJamSessionsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No pudimos cargar las jam sessions.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () =>
                    context.read<PublicJamSessionsCubit>().loadSessions(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No hay jam sessions públicas próximas.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      itemCount: state.sessions.length,
      separatorBuilder: (context, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = state.sessions[index];
        return PublicJamSessionCard(
          session: session,
          currentUserId: state.currentUserId,
          isJoining: state.isJoining(session.id),
          onJoin: () => _handleJoin(context, session),
          onOpenDetail: () =>
              context.push(AppRoutes.jamSessionDetailPath(session.id)),
        );
      },
    );
  }
}
