import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/events_repository.dart';
import '../../domain/event_entity.dart';

class EventsPageState extends Equatable {
  const EventsPageState({
    required this.events,
    required this.loading,
    required this.savingDraft,
    required this.preview,
    required this.draftSavedCount,
    required this.totalCapacity,
    required this.thisWeekCount,
  });

  const EventsPageState.initial()
    : events = const [],
      loading = true,
      savingDraft = false,
      preview = null,
      draftSavedCount = 0,
      totalCapacity = 0,
      thisWeekCount = 0;

  final List<EventEntity> events;
  final bool loading;
  final bool savingDraft;
  final EventEntity? preview;
  final int draftSavedCount;
  final int totalCapacity;
  final int thisWeekCount;

  EventsPageState copyWith({
    List<EventEntity>? events,
    bool? loading,
    bool? savingDraft,
    EventEntity? preview,
    int? draftSavedCount,
    int? totalCapacity,
    int? thisWeekCount,
  }) {
    return EventsPageState(
      events: events ?? this.events,
      loading: loading ?? this.loading,
      savingDraft: savingDraft ?? this.savingDraft,
      preview: preview ?? this.preview,
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
    preview,
    draftSavedCount,
    totalCapacity,
    thisWeekCount,
  ];
}

class EventsPageCubit extends Cubit<EventsPageState> {
  EventsPageCubit({required EventsRepository repository})
    : _repository = repository,
      super(const EventsPageState.initial());

  final EventsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      final events = await _repository.fetchUpcoming();
      if (isClosed) return;
      final summary = _summarize(events);
      emit(
        state.copyWith(
          events: events,
          preview: events.isNotEmpty ? events.first : null,
          loading: false,
          totalCapacity: summary.totalCapacity,
          thisWeekCount: summary.thisWeekCount,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(loading: false));
      rethrow;
    }
  }

  void selectPreview(EventEntity event) {
    emit(state.copyWith(preview: event));
  }

  Future<void> generateDraft(EventEntity event) async {
    emit(state.copyWith(savingDraft: true));
    try {
      final saved = await _repository.saveDraft(event);
      if (isClosed) return;
      final updated = [saved, ...state.events.where((e) => e.id != saved.id)];
      final summary = _summarize(updated);
      emit(
        state.copyWith(
          events: updated,
          preview: saved,
          savingDraft: false,
          draftSavedCount: state.draftSavedCount + 1,
          totalCapacity: summary.totalCapacity,
          thisWeekCount: summary.thisWeekCount,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(savingDraft: false));
      rethrow;
    }
  }

  _EventsSummary _summarize(List<EventEntity> events) {
    final totalCapacity = events.fold<int>(
      0,
      (sum, event) => sum + event.capacity,
    );
    final weekLimit = DateTime.now().add(const Duration(days: 7));
    final thisWeekCount = events
        .where((event) => event.start.isBefore(weekLimit))
        .length;
    return _EventsSummary(
      totalCapacity: totalCapacity,
      thisWeekCount: thisWeekCount,
    );
  }
}

class _EventsSummary {
  const _EventsSummary({
    required this.totalCapacity,
    required this.thisWeekCount,
  });

  final int totalCapacity;
  final int thisWeekCount;
}
