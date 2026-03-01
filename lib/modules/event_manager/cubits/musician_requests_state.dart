import 'package:equatable/equatable.dart';
import '../models/musician_request_entity.dart';

class MusicianRequestsState extends Equatable {
  const MusicianRequestsState({
    this.requests = const [],
    this.isLoading = true,
    this.errorMessage,
  });

  final List<MusicianRequestEntity> requests;
  final bool isLoading;
  final String? errorMessage;

  MusicianRequestsState copyWith({
    List<MusicianRequestEntity>? requests,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MusicianRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [requests, isLoading, errorMessage];
}
