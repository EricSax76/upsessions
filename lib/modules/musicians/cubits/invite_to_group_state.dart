part of 'invite_to_group_cubit.dart';

sealed class InviteToGroupState extends Equatable {
  const InviteToGroupState();

  @override
  List<Object?> get props => const [];
}

final class InviteToGroupInitial extends InviteToGroupState {
  const InviteToGroupInitial();
}

final class InviteToGroupLoading extends InviteToGroupState {
  const InviteToGroupLoading();
}

final class InviteToGroupSuccess extends InviteToGroupState {
  const InviteToGroupSuccess({required this.link, required this.invitePath});

  final String link;
  final String invitePath;

  @override
  List<Object?> get props => [link, invitePath];
}

final class InviteToGroupError extends InviteToGroupState {
  const InviteToGroupError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
