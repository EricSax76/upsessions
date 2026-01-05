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
  });

  const EventsPageState.initial()
    : events = const [],
      loading = true,
      savingDraft = false,
      preview = null,
      draftSavedCount = 0;

  final List<EventEntity> events;
  final bool loading;
  final bool savingDraft;
  final EventEntity? preview;
  final int draftSavedCount;

  EventsPageState copyWith({
    List<EventEntity>? events,
    bool? loading,
    bool? savingDraft,
    EventEntity? preview,
    int? draftSavedCount,
  }) {
    return EventsPageState(
      events: events ?? this.events,
      loading: loading ?? this.loading,
      savingDraft: savingDraft ?? this.savingDraft,
      preview: preview ?? this.preview,
      draftSavedCount: draftSavedCount ?? this.draftSavedCount,
    );
  }

  @override
  List<Object?> get props => [
    events,
    loading,
    savingDraft,
    preview,
    draftSavedCount,
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
      emit(
        state.copyWith(
          events: events,
          preview: events.isNotEmpty ? events.first : null,
          loading: false,
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
      emit(
        state.copyWith(
          events: updated,
          preview: saved,
          savingDraft: false,
          draftSavedCount: state.draftSavedCount + 1,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(savingDraft: false));
      rethrow;
    }
  }
}
