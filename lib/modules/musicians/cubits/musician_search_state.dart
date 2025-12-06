part of 'musician_search_cubit.dart';

class MusicianSearchState extends Equatable {
  const MusicianSearchState({
    this.results = const [],
    this.isLoading = false,
    this.query = '',
    this.errorMessage,
  });

  static const Object _unset = Object();

  final List<MusicianEntity> results;
  final bool isLoading;
  final String query;
  final String? errorMessage;

  MusicianSearchState copyWith({
    List<MusicianEntity>? results,
    bool? isLoading,
    String? query,
    Object? errorMessage = _unset,
  }) {
    return MusicianSearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [results, isLoading, query, errorMessage];
}
