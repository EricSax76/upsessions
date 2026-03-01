import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/events/models/event_entity.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/event_manager/cubits/manager_agenda_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/manager_agenda_state.dart';
import 'package:upsessions/modules/event_manager/repositories/manager_events_repository.dart';
import 'package:upsessions/modules/jam_sessions/models/jam_session_entity.dart';
import 'package:upsessions/modules/jam_sessions/repositories/jam_sessions_repository.dart';

class _MockManagerEventsRepository extends Mock
    implements ManagerEventsRepository {}

class _MockJamSessionsRepository extends Mock
    implements JamSessionsRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockManagerEventsRepository eventsRepository;
  late _MockJamSessionsRepository jamSessionsRepository;
  late _MockAuthRepository authRepository;

  const user = UserEntity(
    id: 'manager-1',
    email: 'mgr@test.com',
    displayName: 'Mgr',
  );

  final upcomingEvents = [
    EventEntity(
      id: 'e1',
      ownerId: 'manager-1',
      title: 'Rock Night',
      city: 'Madrid',
      venue: 'Sala Sol',
      start: DateTime(2026, 4, 10),
      end: DateTime(2026, 4, 10, 23),
      description: 'desc',
      organizer: 'org',
      contactEmail: 'e@e.com',
      contactPhone: '123',
      lineup: const [],
      tags: const [],
      ticketInfo: '',
      capacity: 200,
      resources: const [],
    ),
  ];

  final upcomingSessions = [
    JamSessionEntity(
      id: 'js1',
      ownerId: 'manager-1',
      title: 'Jazz Jam',
      description: 'Open jam',
      date: DateTime(2026, 4, 5),
      time: '20:00',
      location: 'Café Central',
      city: 'Madrid',
    ),
  ];

  setUp(() {
    eventsRepository = _MockManagerEventsRepository();
    jamSessionsRepository = _MockJamSessionsRepository();
    authRepository = _MockAuthRepository();
  });

  ManagerAgendaCubit buildCubit() {
    return ManagerAgendaCubit(
      eventsRepository: eventsRepository,
      jamSessionsRepository: jamSessionsRepository,
      authRepository: authRepository,
    );
  }

  group('ManagerAgendaCubit', () {
    test('estado inicial tiene isLoading true y items vacíos', () {
      final cubit = buildCubit();
      expect(cubit.state.isLoading, true);
      expect(cubit.state.items, isEmpty);
      cubit.close();
    });

    blocTest<ManagerAgendaCubit, ManagerAgendaState>(
      'loadAgenda combina eventos y jam sessions ordenados por fecha',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(() => eventsRepository.fetchUpcoming('manager-1'))
            .thenAnswer((_) async => upcomingEvents);
        when(() => jamSessionsRepository.fetchUpcoming('manager-1'))
            .thenAnswer((_) async => upcomingSessions);
        return buildCubit();
      },
      act: (cubit) => cubit.loadAgenda(),
      expect: () => [
        isA<ManagerAgendaState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<ManagerAgendaState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.items.length, 'count', 2)
            // Jam session (Apr 5) should be before Event (Apr 10)
            .having((s) => s.items.first.type, 'first type', 'Jam Session')
            .having((s) => s.items.last.type, 'last type', 'Evento'),
      ],
    );

    blocTest<ManagerAgendaCubit, ManagerAgendaState>(
      'loadAgenda funciona con solo jam sessions (sin eventos)',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(() => eventsRepository.fetchUpcoming('manager-1'))
            .thenAnswer((_) async => []);
        when(() => jamSessionsRepository.fetchUpcoming('manager-1'))
            .thenAnswer((_) async => upcomingSessions);
        return buildCubit();
      },
      act: (cubit) => cubit.loadAgenda(),
      expect: () => [
        isA<ManagerAgendaState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<ManagerAgendaState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.items.length, 'count', 1)
            .having((s) => s.items.first.type, 'type', 'Jam Session'),
      ],
    );

    blocTest<ManagerAgendaCubit, ManagerAgendaState>(
      'loadAgenda emite error cuando no hay usuario autenticado',
      build: () {
        when(() => authRepository.currentUser).thenReturn(null);
        return buildCubit();
      },
      act: (cubit) => cubit.loadAgenda(),
      expect: () => [
        isA<ManagerAgendaState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<ManagerAgendaState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('No autenticado')),
      ],
    );

    blocTest<ManagerAgendaCubit, ManagerAgendaState>(
      'loadAgenda emite error cuando falla un repositorio',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(() => eventsRepository.fetchUpcoming('manager-1'))
            .thenThrow(Exception('events error'));
        when(() => jamSessionsRepository.fetchUpcoming('manager-1'))
            .thenAnswer((_) async => []);
        return buildCubit();
      },
      act: (cubit) => cubit.loadAgenda(),
      expect: () => [
        isA<ManagerAgendaState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<ManagerAgendaState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('events error')),
      ],
    );
  });
}
