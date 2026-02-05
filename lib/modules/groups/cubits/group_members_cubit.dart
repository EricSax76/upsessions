import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/locator/locator.dart';
import '../repositories/groups_repository.dart';
import 'group_members_state.dart';

class GroupMembersCubit extends Cubit<GroupMembersState> {
  GroupMembersCubit({
    required String groupId,
    GroupsRepository? groupsRepository,
  })  : _groupId = groupId,
        _groupsRepository = groupsRepository ?? locate<GroupsRepository>(),
        super(const GroupMembersLoading()) {
    _init();
  }

  final String _groupId;
  final GroupsRepository _groupsRepository;
  StreamSubscription? _subscription;

  void _init() {
    try {
      _subscription = _groupsRepository
          .watchGroupMembers(_groupId)
          .listen(
            (members) => emit(GroupMembersLoaded(members)),
            onError: (error) => emit(GroupMembersError(error.toString())),
          );
    } catch (error) {
      emit(GroupMembersError(error.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
