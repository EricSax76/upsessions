import 'package:bloc/bloc.dart';
import '../../auth/repositories/auth_repository.dart';
import '../repositories/manager_events_repository.dart';
import '../../jam_sessions/repositories/jam_sessions_repository.dart';
import 'manager_agenda_state.dart';

class ManagerAgendaCubit extends Cubit<ManagerAgendaState> {
  ManagerAgendaCubit({
    required ManagerEventsRepository eventsRepository,
    required JamSessionsRepository jamSessionsRepository,
    required AuthRepository authRepository,
  })  : _eventsRepository = eventsRepository,
        _jamSessionsRepository = jamSessionsRepository,
        _authRepository = authRepository,
        super(const ManagerAgendaState());

  final ManagerEventsRepository _eventsRepository;
  final JamSessionsRepository _jamSessionsRepository;
  final AuthRepository _authRepository;

  void _safeEmit(ManagerAgendaState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadAgenda() async {
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final managerId = _authRepository.currentUser?.id ?? '';
      if (managerId.isEmpty) throw Exception('No autenticado');

      final futures = await Future.wait([
        _eventsRepository.fetchUpcoming(managerId),
        _jamSessionsRepository.fetchUpcoming(managerId),
      ]);

      final events = (futures[0] as List<dynamic>).map((dynamic e) => ManagerAgendaItem(
            id: e.id as String,
            title: e.title as String,
            date: e.start as DateTime,
            type: 'Evento',
            city: e.city as String,
            location: e.venue as String,
          ));

      final sessions = (futures[1] as List<dynamic>).map((dynamic s) {
        return ManagerAgendaItem(
          id: s.id as String,
          title: s.title as String,
          date: s.date as DateTime? ?? DateTime.now(),
          type: 'Jam Session',
          city: s.city as String,
          location: s.location as String,
        );
      });

      final combined = [...events, ...sessions];
      combined.sort((a, b) => a.date.compareTo(b.date));

      _safeEmit(state.copyWith(isLoading: false, items: combined));
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
