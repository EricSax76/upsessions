import 'package:equatable/equatable.dart';

import '../models/event_entity.dart';

class EventsPageState extends Equatable {
  const EventsPageState({
    required this.events,
    required this.loading,
    required this.savingDraft,
    required this.draftSavedCount,
    required this.totalCapacity,
    required this.thisWeekCount,
  });

  const EventsPageState.initial()
    : events = const [],
      loading = true,
      savingDraft = false,
      draftSavedCount = 0,
      totalCapacity = 0,
      thisWeekCount = 0;

  final List<EventEntity> events;
  final bool loading;
  final bool savingDraft;
  final int draftSavedCount;
  final int totalCapacity;
  final int thisWeekCount;

  EventsPageState copyWith({
    List<EventEntity>? events,
    bool? loading,
    bool? savingDraft,
    int? draftSavedCount,
    int? totalCapacity,
    int? thisWeekCount,
  }) {
    return EventsPageState(
      events: events ?? this.events,
      loading: loading ?? this.loading,
      savingDraft: savingDraft ?? this.savingDraft,
      draftSavedCount: draftSavedCount ?? this.draftSavedCount,
      totalCapacity: totalCapacity ?? this.totalCapacity,
      thisWeekCount: thisWeekCount ?? this.thisWeekCount,
    );
  }

  @override
  List<Object?> get props => [
    events,
    loading,
    savingDraft,
    draftSavedCount,
    totalCapacity,
    thisWeekCount,
  ];
}
