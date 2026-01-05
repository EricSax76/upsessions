import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../cubits/rehearsal_entity.dart';
import 'group_rehearsals_controller.dart';
import '../widgets/invite_musician_dialog.dart';
import '../widgets/rehearsal_card.dart';
import '../widgets/rehearsal_dialog.dart';
import '../widgets/rehearsal_helpers.dart';
import '../widgets/summary_card.dart';

class GroupRehearsalsPage extends StatelessWidget {
  const GroupRehearsalsPage({
    super.key,
    required this.groupId,
    this.controller,
  });

  final String groupId;
  final GroupRehearsalsController? controller;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(
      child: GroupRehearsalsView(groupId: groupId, controller: controller),
    );
  }
}

class GroupRehearsalsView extends StatelessWidget {
  const GroupRehearsalsView({
    super.key,
    required this.groupId,
    this.controller,
  });

  final String groupId;
  final GroupRehearsalsController? controller;

  @override
  Widget build(BuildContext context) {
    final controller =
        this.controller ?? GroupRehearsalsController.fromLocator();

    return StreamBuilder<String>(
      stream: controller.watchGroupName(groupId),
      builder: (context, groupNameSnapshot) {
        final groupName = groupNameSnapshot.data ?? 'Grupo';
        return StreamBuilder<String?>(
          stream: controller.watchMyRole(groupId),
          builder: (context, roleSnapshot) {
            final role = roleSnapshot.data ?? '';
            final canManageMembers = role == 'owner' || role == 'admin';
            return StreamBuilder<List<RehearsalEntity>>(
              stream: controller.watchRehearsals(groupId),
              builder: (context, rehearsalsSnapshot) {
                if (rehearsalsSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const LoadingIndicator();
                }
                if (rehearsalsSnapshot.hasError) {
                  return Center(
                    child: Text('Error: ${rehearsalsSnapshot.error}'),
                  );
                }

                final rehearsals = rehearsalsSnapshot.data ?? const [];
                final nextRehearsal = nextUpcomingRehearsal(rehearsals);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  children: [
                    Text(
                      groupName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ensayos',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSurface,
                          ),
                          onPressed: () =>
                              _createRehearsal(context, controller),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Nuevo ensayo'),
                        ),
                        OutlinedButton.icon(
                          onPressed: canManageMembers
                              ? () => _openInviteDialog(context, controller)
                              : null,
                          icon: const Icon(Icons.person_add_alt_1_outlined),
                          label: Text(
                            canManageMembers
                                ? 'Agregar musico'
                                : 'Solo owner/admin',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SummaryCard(
                      totalCount: rehearsals.length,
                      nextRehearsal: nextRehearsal,
                    ),
                    const SizedBox(height: 8),
                    if (rehearsals.isEmpty)
                      const EmptyRehearsalsCard()
                    else
                      for (final rehearsal in rehearsals)
                        RehearsalCard(
                          rehearsal: rehearsal,
                          onTap: () => context.go(
                            AppRoutes.rehearsalDetail(
                              groupId: groupId,
                              rehearsalId: rehearsal.id,
                            ),
                          ),
                        ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _createRehearsal(
    BuildContext context,
    GroupRehearsalsController controller,
  ) async {
    final draft = await showDialog<RehearsalDraft?>(
      context: context,
      builder: (context) => const RehearsalDialog(),
    );
    if (draft == null) return;

    try {
      final rehearsalId = await controller.createRehearsal(
        groupId: groupId,
        startsAt: draft.startsAt,
        endsAt: draft.endsAt,
        location: draft.location,
        notes: draft.notes,
      );
      if (!context.mounted) return;
      context.go(
        AppRoutes.rehearsalDetail(groupId: groupId, rehearsalId: rehearsalId),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear el ensayo: $error')),
      );
    }
  }

  Future<void> _openInviteDialog(
    BuildContext context,
    GroupRehearsalsController controller,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) =>
          InviteMusicianDialog(groupId: groupId, controller: controller),
    );
  }
}

class EmptyRehearsalsCard extends StatelessWidget {
  const EmptyRehearsalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.event_available_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Todavia no hay ensayos. Crea el primero.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
