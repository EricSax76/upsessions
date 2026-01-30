import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/setlist_repository.dart';

import '../../../../core/locator/locator.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/cubits/auth_cubit.dart';
import '../../../groups/repositories/groups_repository.dart';
import '../../cubits/rehearsal_detail_cubit.dart';
import '../../cubits/rehearsal_detail_state.dart';
import '../../application/rehearsal_actions_service.dart';
import '../widgets/rehearsal_detail/rehearsal_detail_widgets.dart';
import '../../application/setlist_actions_service.dart';
import '../../../../core/services/dialog_service.dart';

class RehearsalDetailView extends StatelessWidget {
  const RehearsalDetailView({
    super.key,
    required this.groupId,
    required this.rehearsalId,
    this.rehearsalsRepository,
    this.setlistRepository,
    this.groupsRepository,
  });

  final String groupId;
  final String rehearsalId;
  final RehearsalsRepository? rehearsalsRepository;
  final SetlistRepository? setlistRepository;
  final GroupsRepository? groupsRepository;

  @override
  Widget build(BuildContext context) {
    final userId = context.select((AuthCubit cubit) => cubit.state.user?.id);

    return BlocProvider(
      create: (context) => RehearsalDetailCubit(
        groupId: groupId,
        rehearsalId: rehearsalId,
        userId: userId,
        groupsRepository: groupsRepository ?? locate<GroupsRepository>(),
        rehearsalsRepository:
            rehearsalsRepository ?? locate<RehearsalsRepository>(),
        setlistRepository: setlistRepository ?? locate<SetlistRepository>(),
      ),
      child: const _RehearsalDetailViewBody(),
    );
  }
}

class _RehearsalDetailViewBody extends StatelessWidget {
  const _RehearsalDetailViewBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RehearsalDetailCubit, RehearsalDetailState>(
      builder: (context, state) {
        if (state is RehearsalDetailLoading) {
          return const LoadingIndicator();
        }

        if (state is RehearsalDetailError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is RehearsalDetailNotFound) {
          return Center(child: Text(state.message));
        }

        if (state is RehearsalDetailLoaded) {
          final cubit = context.read<RehearsalDetailCubit>();
          final rehearsalActions = RehearsalActionsService(
            repository: cubit.rehearsalsRepository,
          );
          final setlistActions = SetlistActionsService(
            rehearsalsRepository: cubit.rehearsalsRepository,
            setlistRepository: cubit.setlistRepository,
          );
          return RehearsalDetailContent(
            rehearsal: state.rehearsal,
            setlist: state.setlist,
            onEditRehearsal: () => rehearsalActions.editRehearsal(
              context: context,
              groupId: cubit.groupId,
              rehearsal: state.rehearsal,
            ),
            onDeleteRehearsal: state.canDelete
                ? () => rehearsalActions.confirmDeleteRehearsal(
                    context: context,
                    groupId: cubit.groupId,
                    rehearsalId: cubit.rehearsalId,
                  )
                : null,
            onCopyFromLast: () => setlistActions.copySetlistFromLastRehearsal(
              context: context,
              groupId: cubit.groupId,
              currentRehearsal: state.rehearsal,
              currentSetlist: state.setlist,
            ),
            onAddSong: () => setlistActions.addSetlistItem(
              context: context,
              groupId: cubit.groupId,
              rehearsalId: cubit.rehearsalId,
              current: state.setlist,
            ),
            onEditSong: (item) => setlistActions.editSetlistItem(
              context: context,
              groupId: cubit.groupId,
              rehearsalId: cubit.rehearsalId,
              item: item,
            ),
            onDeleteSong: (item) => setlistActions.confirmDeleteSetlistItem(
              context: context,
              groupId: cubit.groupId,
              rehearsalId: cubit.rehearsalId,
              item: item,
            ),
            onReorderSetlist: (itemIdsInOrder) async {
              try {
                await cubit.reorderSetlist(itemIdsInOrder);
              } catch (error) {
                if (!context.mounted) return;
                DialogService.showError(
                  context,
                  'No se pudo reordenar el setlist: $error',
                );
              }
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
