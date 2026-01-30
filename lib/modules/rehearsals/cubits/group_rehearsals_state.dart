import 'package:equatable/equatable.dart';

import '../../groups/models/group_dtos.dart';
import '../models/rehearsal_entity.dart';

abstract class GroupRehearsalsState extends Equatable {
  const GroupRehearsalsState();

  @override
  List<Object?> get props => [];
}

class GroupRehearsalsLoading extends GroupRehearsalsState {}

class GroupRehearsalsLoaded extends GroupRehearsalsState {
  const GroupRehearsalsLoaded({
    required this.group,
    required this.role,
    required this.rehearsals,
  });

  final GroupDoc? group;
  final String role;
  final List<RehearsalEntity> rehearsals;

  @override
  List<Object?> get props => [group, role, rehearsals];
}

class GroupRehearsalsError extends GroupRehearsalsState {
  const GroupRehearsalsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
