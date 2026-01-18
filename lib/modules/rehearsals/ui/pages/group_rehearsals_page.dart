import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../cubits/rehearsal_entity.dart';
import '../../controllers/group_rehearsals_controller.dart';
import '../../controllers/invite_musician_dialog.dart';
import '../widgets/rehearsal_card.dart';
import '../../controllers/rehearsal_dialog.dart';
import '../../controllers/rehearsal_helpers.dart';
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
    this.showHeader = true,
    this.padding,
  });

  final String groupId;
  final GroupRehearsalsController? controller;
  final bool showHeader;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final controller =
        this.controller ?? GroupRehearsalsController.fromLocator();

    return _GroupRehearsalsBody(
      groupId: groupId,
      controller: controller,
      showHeader: showHeader,
      padding: padding,
    );
  }
}

class EmptyRehearsalsCard extends StatelessWidget {
  const EmptyRehearsalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateCard(
      icon: Icons.event_available_outlined,
      title: 'Todavía no hay ensayos',
      subtitle: 'Crea el primero para empezar a armar el setlist.',
    );
  }
}

enum _RehearsalFilter { upcoming, all, past }

class _GroupRehearsalsBody extends StatefulWidget {
  const _GroupRehearsalsBody({
    required this.groupId,
    required this.controller,
    this.showHeader = true,
    this.padding,
  });

  final String groupId;
  final GroupRehearsalsController controller;
  final bool showHeader;
  final EdgeInsets? padding;

  @override
  State<_GroupRehearsalsBody> createState() => _GroupRehearsalsBodyState();
}

class _GroupRehearsalsBodyState extends State<_GroupRehearsalsBody> {
  _RehearsalFilter _filter = _RehearsalFilter.upcoming;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder<String>(
      stream: controller.watchGroupName(widget.groupId),
      builder: (context, groupNameSnapshot) {
        final groupName = groupNameSnapshot.data ?? 'Grupo';
        return StreamBuilder<String?>(
          stream: controller.watchMyRole(widget.groupId),
          builder: (context, roleSnapshot) {
            final role = roleSnapshot.data ?? '';
            final canManageMembers = role == 'owner' || role == 'admin';
            return StreamBuilder<List<RehearsalEntity>>(
              stream: controller.watchRehearsals(widget.groupId),
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
                final filtered = _applyFilter(rehearsals, _filter);

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final loc = AppLocalizations.of(context);
                    final horizontalPadding = constraints.maxWidth < 420
                        ? 16.0
                        : (constraints.maxWidth < 720 ? 20.0 : 24.0);

                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 860),
                        child: ListView(
                          padding: widget.padding ?? EdgeInsets.fromLTRB(
                            horizontalPadding,
                            16,
                            horizontalPadding,
                            32,
                          ),
                          children: [
                            if (widget.showHeader) ...[
                              Text(
                                groupName,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                loc.navRehearsals,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 16),
                            ],
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        scheme.surfaceContainerHighest,
                                    foregroundColor: scheme.onSurface,
                                  ),
                                  onPressed: () =>
                                      _createRehearsal(context, controller),
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Nuevo ensayo'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: canManageMembers
                                      ? () => _openInviteDialog(
                                          context,
                                          controller,
                                        )
                                      : null,
                                  icon: const Icon(
                                    Icons.person_add_alt_1_outlined,
                                  ),
                                  label: Text(
                                    canManageMembers
                                        ? 'Agregar músico'
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
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('Próximos'),
                                  selected:
                                      _filter == _RehearsalFilter.upcoming,
                                  onSelected: (_) => setState(() {
                                    _filter = _RehearsalFilter.upcoming;
                                  }),
                                ),
                                ChoiceChip(
                                  label: const Text('Todos'),
                                  selected: _filter == _RehearsalFilter.all,
                                  onSelected: (_) => setState(() {
                                    _filter = _RehearsalFilter.all;
                                  }),
                                ),
                                ChoiceChip(
                                  label: const Text('Pasados'),
                                  selected: _filter == _RehearsalFilter.past,
                                  onSelected: (_) => setState(() {
                                    _filter = _RehearsalFilter.past;
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (rehearsals.isEmpty)
                              const EmptyRehearsalsCard()
                            else if (filtered.isEmpty)
                              _EmptyFilterCard(filter: _filter)
                            else
                              for (final rehearsal in filtered)
                                RehearsalCard(
                                  rehearsal: rehearsal,
                                  onTap: () => context.go(
                                    AppRoutes.rehearsalDetail(
                                      groupId: widget.groupId,
                                      rehearsalId: rehearsal.id,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  List<RehearsalEntity> _applyFilter(
    List<RehearsalEntity> items,
    _RehearsalFilter filter,
  ) {
    if (items.isEmpty) return const [];
    final now = DateTime.now();
    switch (filter) {
      case _RehearsalFilter.upcoming:
        return items.where((r) => r.startsAt.isAfter(now)).toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      case _RehearsalFilter.past:
        return items.where((r) => !r.startsAt.isAfter(now)).toList()
          ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
      case _RehearsalFilter.all:
        return [...items]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    }
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
        groupId: widget.groupId,
        startsAt: draft.startsAt,
        endsAt: draft.endsAt,
        location: draft.location,
        notes: draft.notes,
      );
      if (!context.mounted) return;
      context.go(
        AppRoutes.rehearsalDetail(
          groupId: widget.groupId,
          rehearsalId: rehearsalId,
        ),
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
          InviteMusicianDialog(groupId: widget.groupId, controller: controller),
    );
  }
}

class _EmptyFilterCard extends StatelessWidget {
  const _EmptyFilterCard({required this.filter});

  final _RehearsalFilter filter;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      _RehearsalFilter.upcoming => 'No hay ensayos próximos.',
      _RehearsalFilter.past => 'Todavía no hay ensayos pasados.',
      _RehearsalFilter.all => 'No hay ensayos para mostrar.',
    };
    return EmptyStateCard(
      icon: Icons.filter_alt_outlined,
      title: 'Sin resultados',
      subtitle: label,
    );
  }
}
