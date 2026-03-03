import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/events/models/event_entity.dart';
import 'package:upsessions/features/events/models/event_enums.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/event_manager/cubits/manager_dashboard_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/manager_dashboard_state.dart';
import 'package:upsessions/modules/event_manager/repositories/manager_events_repository.dart';

class _MockManagerEventsRepository extends Mock
    implements ManagerEventsRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

EventEntity _event({
  required String id,
  required DateTime start,
  int capacity = 100,
}) {
  return EventEntity(
    id: id,
    ownerId: 'manager-1',
    title: 'Event $id',
    city: 'Madrid',
    venue: 'Venue',
    start: start,
    end: start.add(const Duration(hours: 3)),
    description: 'desc',
    organizer: 'org',
    contactEmail: 'e@e.com',
    contactPhone: '123',
    lineup: const [],
    tags: const [],
    ticketInfo: '',
    capacity: capacity,
    resources: const [],
    isPublic: true,
    isFree: false,
    updatedAt: start,
    status: EventStatus.draft,
  );
}

void main() {
  late _MockManagerEventsRepository eventsRepository;
  late _MockAuthRepository authRepository;

  final user = UserEntity(
    id: 'manager-1',
    email: 'mgr@test.com',
    displayName: 'Mgr',
    createdAt: DateTime.now(),
  );

  setUp(() {
    eventsRepository = _MockManagerEventsRepository();
    authRepository = _MockAuthRepository();
  });

  ManagerDashboardCubit buildCubit() {
    return ManagerDashboardCubit(
      eventsRepository: eventsRepository,
      authRepository: authRepository,
    );
  }

  group('ManagerDashboardCubit', () {
    test('estado inicial tiene isLoading true', () {
      final cubit = buildCubit();
      expect(cubit.state.isLoading, true);
      expect(cubit.state.upcomingEvents, isEmpty);
      expect(cubit.state.totalEvents, 0);
      cubit.close();
    });

    blocTest<ManagerDashboardCubit, ManagerDashboardState>(
      'loadDashboard carga estadísticas y eventos próximos',
      build: () {
        final now = DateTime.now();
        final allEvents = [
          _event(
            id: 'e1',
            start: now.add(const Duration(days: 2)),
            capacity: 100,
          ),
          _event(
            id: 'e2',
            start: now.add(const Duration(days: 10)),
            capacity: 200,
          ),
          _event(
            id: 'e3',
            start: now.subtract(const Duration(days: 5)),
            capacity: 50,
          ),
        ];
        final upcoming = [allEvents[0], allEvents[1]];

        when(() => authRepository.currentUser).thenReturn(user);
        when(
          () => eventsRepository.fetchMyEvents('manager-1'),
        ).thenAnswer((_) async => allEvents);
        when(
          () => eventsRepository.fetchUpcoming('manager-1'),
        ).thenAnswer((_) async => upcoming);
        return buildCubit();
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        isA<ManagerDashboardState>().having(
          (s) => s.isLoading,
          'loading',
          true,
        ),
        isA<ManagerDashboardState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.totalEvents, 'total', 3)
            .having((s) => s.totalCapacity, 'capacity', 350)
            .having((s) => s.upcomingEvents.length, 'upcoming', 2),
      ],
    );

    blocTest<ManagerDashboardCubit, ManagerDashboardState>(
      'loadDashboard emite error cuando no hay usuario autenticado',
      build: () {
        when(() => authRepository.currentUser).thenReturn(null);
        return buildCubit();
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        isA<ManagerDashboardState>().having(
          (s) => s.isLoading,
          'loading',
          true,
        ),
        isA<ManagerDashboardState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('No autenticado')),
      ],
    );

    blocTest<ManagerDashboardCubit, ManagerDashboardState>(
      'loadDashboard emite error cuando falla el repositorio',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(
          () => eventsRepository.fetchMyEvents('manager-1'),
        ).thenThrow(Exception('network'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadDashboard(),
      expect: () => [
        isA<ManagerDashboardState>().having(
          (s) => s.isLoading,
          'loading',
          true,
        ),
        isA<ManagerDashboardState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('network')),
      ],
    );
  });
}
