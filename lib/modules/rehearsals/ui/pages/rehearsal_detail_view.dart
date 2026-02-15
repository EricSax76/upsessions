import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/setlist_repository.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/cubits/auth_cubit.dart';
import '../../../groups/repositories/groups_repository.dart';
import '../../../studios/ui/consumer/studios_list_page.dart';
import '../../../studios/repositories/studios_repository.dart';
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
    required this.rehearsalsRepository,
    required this.setlistRepository,
    required this.groupsRepository,
    required this.studiosRepository,
  });

  final String groupId;
  final String rehearsalId;
  final RehearsalsRepository rehearsalsRepository;
  final SetlistRepository setlistRepository;
  final GroupsRepository groupsRepository;
  final StudiosRepository studiosRepository;

  @override
  Widget build(BuildContext context) {
    final userId = context.select((AuthCubit cubit) => cubit.state.user?.id);

    return BlocProvider(
      create: (context) => RehearsalDetailCubit(
        groupId: groupId,
        rehearsalId: rehearsalId,
        userId: userId,
        groupsRepository: groupsRepository,
        rehearsalsRepository: rehearsalsRepository,
        setlistRepository: setlistRepository,
        studiosRepository: studiosRepository,
      ),
      child: _RehearsalDetailViewBody(
        groupId: groupId,
        rehearsalId: rehearsalId,
      ),
    );
  }
}

class _RehearsalDetailViewBody extends StatelessWidget {
  const _RehearsalDetailViewBody({
    required this.groupId,
    required this.rehearsalId,
  });

  final String groupId;
  final String rehearsalId;

  void _navigateToStudios(
    BuildContext context,
    DateTime rehearsalDate,
    DateTime? rehearsalEndDate,
  ) {
    context.push(
      AppRoutes.studios,
      extra: RehearsalBookingContext(
        groupId: groupId,
        rehearsalId: rehearsalId,
        suggestedDate: rehearsalDate,
        suggestedEndDate: rehearsalEndDate,
      ),
    );
  }

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
            bookingRoomName: state.booking?.roomName,
            bookingAddress: state.bookingStudio?.address,
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
            onBookRoom: state.rehearsal.bookingId == null
                ? () => _navigateToStudios(
                    context,
                    state.rehearsal.startsAt,
                    state.rehearsal.endsAt,
                  )
                : null,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
