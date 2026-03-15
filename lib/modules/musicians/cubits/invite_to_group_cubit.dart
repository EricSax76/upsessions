import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:upsessions/core/constants/app_link_scheme.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';

part 'invite_to_group_state.dart';

class InviteToGroupCubit extends Cubit<InviteToGroupState> {
  InviteToGroupCubit({required GroupsRepository groupsRepository})
    : _groupsRepository = groupsRepository,
      super(const InviteToGroupInitial());

  final GroupsRepository _groupsRepository;

  Future<void> createInvite({
    required String groupId,
    required String targetUid,
  }) async {
    final normalizedGroupId = groupId.trim();
    final normalizedTargetUid = targetUid.trim();
    if (normalizedGroupId.isEmpty || normalizedTargetUid.isEmpty) {
      emit(const InviteToGroupError('Datos de invitación inválidos.'));
      return;
    }

    emit(const InviteToGroupLoading());
    try {
      final inviteId = await _groupsRepository.createInvite(
        groupId: normalizedGroupId,
        targetUid: normalizedTargetUid,
      );
      final invitePath = AppRoutes.invitePath(
        groupId: normalizedGroupId,
        inviteId: inviteId,
      );
      emit(
        InviteToGroupSuccess(
          invitePath: invitePath,
          link: '$appLinkScheme://$invitePath',
        ),
      );
    } catch (error) {
      emit(InviteToGroupError('No se pudo crear la invitación: $error'));
    }
  }

  void reset() {
    emit(const InviteToGroupInitial());
  }
}
