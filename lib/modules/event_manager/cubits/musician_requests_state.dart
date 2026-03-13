import 'package:equatable/equatable.dart';
import '../models/musician_request_entity.dart';

class MusicianRequestsState extends Equatable {
  static const Object _unset = Object();

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
    Object? errorMessage = _unset,
  }) {
    return MusicianRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [requests, isLoading, errorMessage];
}
