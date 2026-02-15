import 'package:equatable/equatable.dart';
import '../models/group_dtos.dart';

abstract class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {
  const GroupInitial();
}

class GroupLoading extends GroupState {
  const GroupLoading();
}

class GroupLoaded extends GroupState {
  const GroupLoaded(this.group);

  final GroupDoc group;

  @override
  List<Object?> get props => [group];
}

class GroupError extends GroupState {
  const GroupError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
