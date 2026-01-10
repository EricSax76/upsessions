part of 'agenda_cubit.dart';

class AgendaState extends Equatable {
  const AgendaState({
    this.rehearsals = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<RehearsalEntity> rehearsals;
  final bool isLoading;
  final String? errorMessage;

  AgendaState copyWith({
    List<RehearsalEntity>? rehearsals,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AgendaState(
      rehearsals: rehearsals ?? this.rehearsals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [rehearsals, isLoading, errorMessage];
}
