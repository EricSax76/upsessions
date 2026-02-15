part of 'musician_detail_cubit.dart';

sealed class MusicianDetailState extends Equatable {
  const MusicianDetailState();

  @override
  List<Object?> get props => [];
}

final class MusicianDetailInitial extends MusicianDetailState {
  const MusicianDetailInitial();
}

final class MusicianDetailContacting extends MusicianDetailState {
  const MusicianDetailContacting();
}

final class MusicianDetailContactSuccess extends MusicianDetailState {
  const MusicianDetailContactSuccess(this.threadId);

  final String threadId;

  @override
  List<Object?> get props => [threadId];
}

final class MusicianDetailError extends MusicianDetailState {
  const MusicianDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
