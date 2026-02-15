part of 'matching_cubit.dart';

enum MatchingStatus { initial, loading, success, failure }

class MatchingState extends Equatable {
  const MatchingState({
    this.status = MatchingStatus.initial,
    this.matches = const [],
    this.errorMessage,
  });

  final MatchingStatus status;
  final List<MatchingResult> matches;
  final String? errorMessage;

  MatchingState copyWith({
    MatchingStatus? status,
    List<MatchingResult>? matches,
    String? errorMessage,
  }) {
    return MatchingState(
      status: status ?? this.status,
      matches: matches ?? this.matches,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, matches, errorMessage];
}
