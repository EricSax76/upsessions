import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../core/widgets/gap.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../../../home/ui/widgets/home_section_card.dart';
import '../../cubits/rehearsal_entity.dart';
import '../../controllers/group_rehearsals_controller.dart';
import '../../controllers/invite_musician_dialog.dart';
import '../../../groups/models/group_dtos.dart';
import '../widgets/rehearsal_card.dart';
import '../../controllers/rehearsal_dialog.dart';
import '../../controllers/rehearsal_helpers.dart';
import '../widgets/rehearsals_hero_section.dart';

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

    return StreamBuilder<GroupDoc>(
      stream: controller.watchGroup(widget.groupId),
      builder: (context, groupSnapshot) {
        final group = groupSnapshot.data;
        final groupName = group?.name ?? 'Grupo';
        final groupPhotoUrl = group?.photoUrl;

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
                    final width = constraints.maxWidth;
                    final isWide = width >= 1200;
                    final isMedium = width >= 800;
                    final colorScheme = Theme.of(context).colorScheme;
                    final loc = AppLocalizations.of(context);

                    return Container(
                      color: colorScheme.surfaceContainerLow,
                      child: SingleChildScrollView(
                        padding: widget.padding ??
                            EdgeInsets.symmetric(
                              vertical: isWide ? 48 : 24,
                              horizontal: isWide ? 48 : 16,
                            ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.showHeader) ...[
                                  RehearsalsHeroSection(
                                    groupName: groupName,
                                    groupPhotoUrl: groupPhotoUrl,
                                    totalRehearsals: rehearsals.length,
                                    canManageMembers: canManageMembers,
                                    onCreateRehearsal: () =>
                                        _createRehearsal(context, controller),
                                    onInviteMusician: () => _openInviteDialog(
                                      context,
                                      controller,
                                    ),
                                  ),
                                  const Gap(48),
                                ],
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: HomeSectionCard(
                                        title: loc.navRehearsals,
                                        subtitle: loc.rehearsalsPageSubtitle,
                                        action: isMedium ? _buildFilterChips(loc) : null,
                                        child: Column(
                                          children: [
                                            if (!widget.showHeader) ...[
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: _buildCreateButton(
                                                  context,
                                                  loc,
                                                  controller,
                                                ),
                                              ),
                                              const Gap(16),
                                            ],
                                            if (!isMedium) ...[
                                              _buildFilterChips(loc),
                                              const Gap(16),
                                            ],
                                            if (rehearsals.isEmpty)
                                              const EmptyRehearsalsCard()
                                            else if (filtered.isEmpty)
                                              _EmptyFilterCard(filter: _filter)
                                            else
                                              ListView.separated(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: filtered.length,
                                                separatorBuilder: (context, index) =>
                                                    const Gap(12),
                                                itemBuilder: (context, index) {
                                                  final rehearsal = filtered[index];
                                                  return RehearsalCard(
                                                    rehearsal: rehearsal,
                                                    onTap: () => context.go(
                                                      AppRoutes.rehearsalDetail(
                                                        groupId: widget.groupId,
                                                        rehearsalId: rehearsal.id,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (isWide) ...[
                                      const Gap(32),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          children: [
                                            _buildStatsSection(context, nextRehearsal, rehearsals.length, loc),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const Gap(48),
                              ],
                            ),
                          ),
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

  Widget _buildFilterChips(AppLocalizations loc) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text(loc.rehearsalsFilterUpcoming),
          selected: _filter == _RehearsalFilter.upcoming,
          onSelected: (_) => setState(() {
            _filter = _RehearsalFilter.upcoming;
          }),
        ),
        ChoiceChip(
          label: Text(loc.rehearsalsFilterPast),
          selected: _filter == _RehearsalFilter.past,
          onSelected: (_) => setState(() {
            _filter = _RehearsalFilter.past;
          }),
        ),
        ChoiceChip(
          label: Text(loc.rehearsalsFilterAll),
          selected: _filter == _RehearsalFilter.all,
          onSelected: (_) => setState(() {
            _filter = _RehearsalFilter.all;
          }),
        ),
      ],
    );
  }

  Widget _buildCreateButton(
    BuildContext context,
    AppLocalizations loc,
    GroupRehearsalsController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: () => _createRehearsal(context, controller),
      icon: const Icon(Icons.add_circle_outline),
      label: Text(loc.rehearsalsNewButton),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, RehearsalEntity? nextRehearsal, int count, AppLocalizations loc) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return HomeSectionCard(
      title: loc.rehearsalsSummaryTitle,
      child: Column(
        children: [
          _StatTile(
            icon: Icons.calendar_today,
            label: loc.rehearsalsTotalStat,
            value: count.toString(),
            color: colorScheme.primary,
          ),
          const Gap(16),
          _StatTile(
            icon: Icons.next_plan,
            label: loc.rehearsalsNextLabel,
            value: nextRehearsal != null ? formatDateTime(nextRehearsal.startsAt) : loc.rehearsalsNoUpcoming,
            color: colorScheme.secondary,
          ),
        ],
      ),
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
