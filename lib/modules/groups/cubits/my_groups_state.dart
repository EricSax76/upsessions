import 'package:equatable/equatable.dart';
import '../models/group_membership_entity.dart';

sealed class MyGroupsState extends Equatable {
  const MyGroupsState();

  @override
  List<Object?> get props => [];
}

final class MyGroupsInitial extends MyGroupsState {
  const MyGroupsInitial();
}

final class MyGroupsLoading extends MyGroupsState {
  const MyGroupsLoading();
}

final class MyGroupsLoaded extends MyGroupsState {
  const MyGroupsLoaded(this.groups);

  final List<GroupMembershipEntity> groups;

  @override
  List<Object?> get props => [groups];
}

final class MyGroupsError extends MyGroupsState {
  const MyGroupsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
