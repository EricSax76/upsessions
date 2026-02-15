import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../../../core/locator/locator.dart';
import '../../../auth/repositories/auth_repository.dart';
import '../../models/rehearsal_filter.dart';
import '../../../groups/models/group_dtos.dart';
import '../../../groups/repositories/groups_repository.dart';

import '../dialogs/invite_musician_dialog.dart';
import '../dialogs/rehearsal_dialog.dart';
import '../widgets/rehearsal_list_card.dart';
import '../widgets/rehearsal_responsive_layout.dart';
import '../widgets/rehearsal_stats_widget.dart';
import '../widgets/rehearsals_hero_section.dart';
import '../../cubits/group_rehearsals_cubit.dart';
import '../../cubits/group_rehearsals_state.dart';
import '../../models/rehearsal_entity.dart';
import '../../repositories/rehearsals_repository.dart';
import '../../utils/rehearsal_date_utils.dart';

class GroupRehearsalsPage extends StatelessWidget {
  const GroupRehearsalsPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return UserShellPage(child: GroupRehearsalsView(groupId: groupId));
  }
}

class GroupRehearsalsView extends StatefulWidget {
  const GroupRehearsalsView({
    super.key,
    required this.groupId,
    this.showHeader = true,
    this.padding,
  });

  final String groupId;
  final bool showHeader;
  final EdgeInsets? padding;

  @override
  State<GroupRehearsalsView> createState() => _GroupRehearsalsViewState();
}

class _GroupRehearsalsViewState extends State<GroupRehearsalsView> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GroupRehearsalsCubit(
        groupId: widget.groupId,
        groupsRepository: locate<GroupsRepository>(),
        rehearsalsRepository: locate<RehearsalsRepository>(),
        createRehearsalUseCase: locate(),
        musiciansRepository: locate(),
        authRepository: locate<AuthRepository>(),
      ),
      child: _GroupRehearsalsBody(
        groupId: widget.groupId,
        showHeader: widget.showHeader,
        padding: widget.padding,
      ),
    );
  }
}

class _GroupRehearsalsBody extends StatefulWidget {
  const _GroupRehearsalsBody({
    required this.groupId,
    this.showHeader = true,
    this.padding,
  });

  final String groupId;
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
      final rehearsalId = await context
          .read<GroupRehearsalsCubit>()
          .createRehearsal(
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
      builder: (_) => BlocProvider.value(
        value: context.read<GroupRehearsalsCubit>(),
        child: InviteMusicianDialog(groupId: widget.groupId),
      ),
    );
  }
}
