import 'package:equatable/equatable.dart';

import '../models/event_entity.dart';

enum EventDetailStatus { idle, uploadingBanner }

enum EventDetailEffect {
  bannerUpdated,
  bannerCancelled,
  templateCopied,
  shareComingSoon,
}

class EventDetailState extends Equatable {
  const EventDetailState({
    required this.event,
    this.status = EventDetailStatus.idle,
    this.effect,
    this.errorMessage,
  });

  final EventEntity event;
  final EventDetailStatus status;
  final EventDetailEffect? effect;
  final String? errorMessage;

  bool get isUploadingBanner => status == EventDetailStatus.uploadingBanner;

  EventDetailState copyWith({
    EventEntity? event,
    EventDetailStatus? status,
    EventDetailEffect? effect,
    String? errorMessage,
  }) {
    return EventDetailState(
      event: event ?? this.event,
      status: status ?? this.status,
      effect: effect,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [event, status, effect, errorMessage];
}
