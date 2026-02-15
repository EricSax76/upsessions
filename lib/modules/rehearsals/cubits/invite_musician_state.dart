import 'package:flutter/foundation.dart';

import '../../musicians/models/musician_entity.dart';

@immutable
class InviteMusicianState {
  const InviteMusicianState({
    required this.query,
    required this.isLoading,
    required this.results,
  });

  const InviteMusicianState.initial()
      : query = '',
        isLoading = false,
        results = const [];

  final String query;
  final bool isLoading;
  final List<MusicianEntity> results;

  bool get hasQuery => query.trim().isNotEmpty;
  bool get hasResults => results.isNotEmpty;

  InviteMusicianState copyWith({
    String? query,
    bool? isLoading,
    List<MusicianEntity>? results,
  }) {
    return InviteMusicianState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
    );
  }
}
