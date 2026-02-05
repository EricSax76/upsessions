import 'package:equatable/equatable.dart';

import '../models/group_member.dart';

abstract class GroupMembersState extends Equatable {
  const GroupMembersState();

  @override
  List<Object?> get props => [];
}

class GroupMembersLoading extends GroupMembersState {
  const GroupMembersLoading();
}

class GroupMembersLoaded extends GroupMembersState {
  const GroupMembersLoaded(this.members);

  final List<GroupMember> members;

  @override
  List<Object?> get props => [members];
}

class GroupMembersError extends GroupMembersState {
  const GroupMembersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
