import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../auth/repositories/auth_repository.dart';
import '../../models/rehearsal_filter.dart';
import '../../../groups/models/group_dtos.dart';
import '../../../groups/repositories/groups_repository.dart';

import '../../../musicians/repositories/musicians_repository.dart';

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
import '../../use_cases/create_rehearsal_use_case.dart';
import '../../utils/rehearsal_date_utils.dart';

class GroupRehearsalsPage extends StatelessWidget {
  const GroupRehearsalsPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return GroupRehearsalsView(groupId: groupId);
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
        groupsRepository: context.read<GroupsRepository>(),
        rehearsalsRepository: context.read<RehearsalsRepository>(),
        createRehearsalUseCase: context.read<CreateRehearsalUseCase>(),
        musiciansRepository: context.read<MusiciansRepository>(),
        authRepository: context.read<AuthRepository>(),
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
    final loc = AppLocalizations.of(context);
    return BlocBuilder<GroupRehearsalsCubit, GroupRehearsalsState>(
      builder: (context, state) {
        if (state is GroupRehearsalsLoading) {
          return const LoadingIndicator();
        }
        if (state is GroupRehearsalsError) {
          return Center(
            child: Text(loc.rehearsalsErrorWithMessage(state.message)),
          );
        }
        if (state is GroupRehearsalsLoaded) {
          return _buildContent(
            context: context,
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
    required BuildContext context,
    required GroupDoc? group,
    required String role,
    required List<RehearsalEntity> rehearsals,
  }) {
    final loc = AppLocalizations.of(context);
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
                  groupName: group?.name ?? loc.rehearsalsGroupFallbackName,
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
    final loc = AppLocalizations.of(context);
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
      DialogService.showError(
        context,
        loc.rehearsalsCreateError(error.toString()),
      );
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
