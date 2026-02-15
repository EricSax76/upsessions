import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/events_repository.dart';
import '../models/event_entity.dart';
import 'events_page_state.dart';

export 'events_page_state.dart';

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
    //
  }

  Future<void> generateDraft(EventEntity event) async {
    emit(state.copyWith(savingDraft: true));
    try {
      await _repository.saveDraft(event);
      if (isClosed) return;
      emit(
        state.copyWith(
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
