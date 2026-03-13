import 'package:equatable/equatable.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';

class HireMusiciansState extends Equatable {
  static const _unset = Object();

  const HireMusiciansState({
    this.musicians = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  final List<MusicianEntity> musicians;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  HireMusiciansState copyWith({
    List<MusicianEntity>? musicians,
    bool? isLoading,
    Object? error = _unset,
    String? searchQuery,
  }) {
    return HireMusiciansState(
      musicians: musicians ?? this.musicians,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [musicians, isLoading, error, searchQuery];
}
