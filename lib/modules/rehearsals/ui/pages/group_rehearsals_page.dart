import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../models/rehearsal_entity.dart';
import '../../cubits/group_rehearsals_cubit.dart';
import '../../cubits/group_rehearsals_state.dart';
import '../../controllers/group_rehearsals_controller.dart';
import '../dialogs/invite_musician_dialog.dart';
import '../../../groups/models/group_dtos.dart';
import '../dialogs/rehearsal_dialog.dart';
import '../../utils/rehearsal_date_utils.dart';
import '../widgets/rehearsals_hero_section.dart';
import '../widgets/rehearsal_list_card.dart';
import '../widgets/rehearsal_stats_widget.dart';
import '../widgets/rehearsal_responsive_layout.dart';
import '../../controllers/rehearsal_filter.dart';

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

class GroupRehearsalsView extends StatefulWidget {
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
  State<GroupRehearsalsView> createState() => _GroupRehearsalsViewState();
}

class _GroupRehearsalsViewState extends State<GroupRehearsalsView> {
  late final GroupRehearsalsController _controller =
      widget.controller ?? GroupRehearsalsController.fromLocator();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupRehearsalsCubit(
        groupId: widget.groupId,
        controller: _controller,
      ),
      child: _GroupRehearsalsBody(
        groupId: widget.groupId,
        controller: _controller,
        showHeader: widget.showHeader,
        padding: widget.padding,
      ),
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
    return BlocBuilder<GroupRehearsalsCubit, GroupRehearsalsState>(
      builder: (context, state) {
        if (state is GroupRehearsalsLoading) {
          return const LoadingIndicator();
        }
        if (state is GroupRehearsalsError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is GroupRehearsalsLoaded) {
          return _buildContent(
            group: state.group,
            role: state.role,
            rehearsals: state.rehearsals,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent({
    required GroupDoc? group,
    required String role,
    required List<RehearsalEntity> rehearsals,
  }) {
    final now = DateTime.now();
    final canManageMembers = role == 'owner' || role == 'admin';
    final filtered = applyRehearsalFilter(rehearsals, _filter, now: now);

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
            nextRehearsal: nextUpcomingRehearsal(rehearsals, now: now),
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
