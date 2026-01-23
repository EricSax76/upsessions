import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../cubits/rehearsal_entity.dart';
import '../../controllers/group_rehearsals_controller.dart';
import '../../controllers/invite_musician_dialog.dart';
import '../../../groups/models/group_dtos.dart';
import '../../controllers/rehearsal_dialog.dart';
import '../../controllers/rehearsal_helpers.dart';
import '../widgets/rehearsals_hero_section.dart';
import '../widgets/rehearsal_list_card.dart';
import '../widgets/rehearsal_stats_widget.dart';
import '../widgets/rehearsal_responsive_layout.dart';
import '../models/rehearsal_filter.dart';
import '../utils/rehearsal_utils.dart';

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
  RehearsalFilter _filter = RehearsalFilter.upcoming;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GroupDoc>(
      stream: widget.controller.watchGroup(widget.groupId),
      builder: (context, groupSnapshot) {
        return StreamBuilder<String?>(
          stream: widget.controller.watchMyRole(widget.groupId),
          builder: (context, roleSnapshot) {
            return StreamBuilder<List<RehearsalEntity>>(
              stream: widget.controller.watchRehearsals(widget.groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                return _buildContent(
                  group: groupSnapshot.data,
                  role: roleSnapshot.data ?? '',
                  rehearsals: snapshot.data ?? const [],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContent({
    required GroupDoc? group,
    required String role,
    required List<RehearsalEntity> rehearsals,
  }) {
    final canManageMembers = role == 'owner' || role == 'admin';
    final filtered = applyRehearsalFilter(rehearsals, _filter);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMedium = constraints.maxWidth >= 800;

        return RehearsalResponsiveLayout(
          padding: widget.padding,
          header: widget.showHeader
              ? RehearsalsHeroSection(
                  groupName: group?.name ?? 'Grupo',
                  groupPhotoUrl: group?.photoUrl,
                  totalRehearsals: rehearsals.length,
                  canManageMembers: canManageMembers,
                  onCreateRehearsal: _handleCreateRehearsal,
                  onInviteMusician: _handleInviteMusician,
                )
              : null,
          mainContent: RehearsalListCard(
            rehearsals: rehearsals,
            filtered: filtered,
            currentFilter: _filter,
            onFilterChanged: (filter) => setState(() => _filter = filter),
            onRehearsalTap: (rehearsal) => context.go(
              AppRoutes.rehearsalDetail(
                groupId: widget.groupId,
                rehearsalId: rehearsal.id,
              ),
            ),
            showCreateButton: !widget.showHeader,
            onCreateRehearsal: _handleCreateRehearsal,
            isMediumScreen: isMedium,
          ),
          sidebar: RehearsalStatsCard(
            nextRehearsal: nextUpcomingRehearsal(rehearsals),
            totalCount: rehearsals.length,
          ),
        );
      },
    );
  }

  Future<void> _handleCreateRehearsal() async {
    final draft = await showDialog<RehearsalDraft?>(
      context: context,
      builder: (context) => const RehearsalDialog(),
    );
    if (draft == null || !mounted) return;

    try {
      final rehearsalId = await widget.controller.createRehearsal(
        groupId: widget.groupId,
        startsAt: draft.startsAt,
        endsAt: draft.endsAt,
        location: draft.location,
        notes: draft.notes,
      );
      if (!mounted) return;
      context.go(
        AppRoutes.rehearsalDetail(
          groupId: widget.groupId,
          rehearsalId: rehearsalId,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      DialogService.showError(context, 'No se pudo crear el ensayo: $error');
    }
  }

  Future<void> _handleInviteMusician() async {
    await showDialog<void>(
      context: context,
      builder: (context) => InviteMusicianDialog(
        groupId: widget.groupId,
        controller: widget.controller,
      ),
    );
  }
}
