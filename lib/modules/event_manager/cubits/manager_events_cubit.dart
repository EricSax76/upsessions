import 'package:bloc/bloc.dart';
import '../../auth/repositories/auth_repository.dart';
import '../repositories/manager_events_repository.dart';
import 'manager_events_state.dart';

class ManagerEventsCubit extends Cubit<ManagerEventsState> {
  ManagerEventsCubit({
    required ManagerEventsRepository repository,
    required AuthRepository authRepository,
  })  : _repository = repository,
        _authRepository = authRepository,
        super(const ManagerEventsState());

  final ManagerEventsRepository _repository;
  final AuthRepository _authRepository;

  void _safeEmit(ManagerEventsState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadEvents() async {
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final managerId = _authRepository.currentUser?.id ?? '';
      if (managerId.isEmpty) throw Exception('No autenticado');
      
      final events = await _repository.fetchMyEvents(managerId);
      _safeEmit(state.copyWith(isLoading: false, events: events));
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void setFilter(ManagerEventFilter filter) {
    _safeEmit(state.copyWith(filter: filter));
    // The UI handles filtering the locally cached `events` list,
    // or we could refetch if pagination is needed. For now, local filtering is enough
    // since `fetchMyEvents` fetches the most recent.
  }

  Future<void> deleteEvent(String eventId) async {
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _repository.delete(eventId);
      final updatedList = state.events.where((e) => e.id != eventId).toList();
      _safeEmit(state.copyWith(isLoading: false, events: updatedList));
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
