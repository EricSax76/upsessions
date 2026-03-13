import 'package:bloc/bloc.dart';
import '../repositories/manager_events_repository.dart';
// import '../../jam_sessions/repositories/jam_sessions_repository.dart';
// import '../repositories/musician_requests_repository.dart';
import '../../auth/repositories/auth_repository.dart';
import 'manager_dashboard_state.dart';

class ManagerDashboardCubit extends Cubit<ManagerDashboardState> {
  ManagerDashboardCubit({
    required ManagerEventsRepository eventsRepository,
    required AuthRepository authRepository,
  }) : _eventsRepository = eventsRepository,
       _authRepository = authRepository,
       super(const ManagerDashboardState());

  final ManagerEventsRepository _eventsRepository;
  final AuthRepository _authRepository;

  void _safeEmit(ManagerDashboardState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadDashboard() async {
    _safeEmit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final managerId = _authRepository.currentUser?.id ?? '';
      if (managerId.isEmpty) throw Exception('No autenticado');

      final allEvents = await _eventsRepository.fetchAllMyEvents(managerId);
      final upcomingEvents = await _eventsRepository.fetchUpcoming(managerId);

      // Calculate stats
      final totalCapacity = allEvents.fold<int>(
        0,
        (sum, event) => sum + event.capacity,
      );
      final now = DateTime.now();
      final weekLimit = now.add(const Duration(days: 7));
      final eventsThisWeek = allEvents
          .where(
            (event) =>
                event.start.isBefore(weekLimit) && event.start.isAfter(now),
          )
          .length;

      // TODO: Fetch from other repositories for Jam Sessions and Requests

      _safeEmit(
        state.copyWith(
          isLoading: false,
          upcomingEvents: upcomingEvents,
          totalEvents: allEvents.length,
          totalCapacity: totalCapacity,
          eventsThisWeek: eventsThisWeek,
          // activeJamSessionsCount: ...,
          // pendingRequestsCount: ...,
        ),
      );
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
