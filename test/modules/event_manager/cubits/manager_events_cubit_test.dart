import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/events/models/event_entity.dart';
import 'package:upsessions/features/events/models/event_enums.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/event_manager/cubits/manager_events_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/manager_events_state.dart';
import 'package:upsessions/modules/event_manager/repositories/manager_events_repository.dart';

class _MockManagerEventsRepository extends Mock
    implements ManagerEventsRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockManagerEventsRepository repository;
  late _MockAuthRepository authRepository;

  final user = UserEntity(
    id: 'manager-1',
    email: 'mgr@test.com',
    displayName: 'Mgr',
    createdAt: DateTime.now(),
  );

  final events = [
    EventEntity(
      id: 'e1',
      ownerId: 'manager-1',
      title: 'Rock Night',
      city: 'Madrid',
      venue: 'Sala Sol',
      start: DateTime(2026, 4, 1),
      end: DateTime(2026, 4, 2),
      description: 'desc',
      organizer: 'org',
      contactEmail: 'e@e.com',
      contactPhone: '123',
      lineup: const [],
      tags: const [],
      ticketInfo: '',
      capacity: 200,
      resources: const [],
      isPublic: true,
      isFree: false,
      updatedAt: DateTime(2026, 4, 1),
      status: EventStatus.draft,
    ),
    EventEntity(
      id: 'e2',
      ownerId: 'manager-1',
      title: 'Blues Fest',
      city: 'Barcelona',
      venue: 'Razzmatazz',
      start: DateTime(2026, 5, 1),
      end: DateTime(2026, 5, 2),
      description: 'desc',
      organizer: 'org',
      contactEmail: 'e@e.com',
      contactPhone: '123',
      lineup: const [],
      tags: const [],
      ticketInfo: '',
      capacity: 500,
      resources: const [],
      isPublic: true,
      isFree: false,
      updatedAt: DateTime(2026, 5, 1),
      status: EventStatus.draft,
    ),
  ];

  setUp(() {
    repository = _MockManagerEventsRepository();
    authRepository = _MockAuthRepository();
  });

  ManagerEventsCubit buildCubit() {
    return ManagerEventsCubit(
      repository: repository,
      authRepository: authRepository,
    );
  }

  group('ManagerEventsCubit', () {
    test('estado inicial tiene isLoading true y lista vacía', () {
      final cubit = buildCubit();
      expect(cubit.state.isLoading, true);
      expect(cubit.state.events, isEmpty);
      expect(cubit.state.filter, ManagerEventFilter.all);
      cubit.close();
    });

    // -- loadEvents --

    blocTest<ManagerEventsCubit, ManagerEventsState>(
      'loadEvents carga los eventos del manager',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(
          () => repository.fetchMyEvents('manager-1'),
        ).thenAnswer((_) async => events);
        return buildCubit();
      },
      act: (cubit) => cubit.loadEvents(),
      expect: () => [
        isA<ManagerEventsState>().having((s) => s.isLoading, 'loading', true),
        isA<ManagerEventsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.events.length, 'count', 2),
      ],
    );

    blocTest<ManagerEventsCubit, ManagerEventsState>(
      'loadEvents emite error cuando no hay usuario autenticado',
      build: () {
        when(() => authRepository.currentUser).thenReturn(null);
        return buildCubit();
      },
      act: (cubit) => cubit.loadEvents(),
      expect: () => [
        isA<ManagerEventsState>().having((s) => s.isLoading, 'loading', true),
        isA<ManagerEventsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('No autenticado')),
      ],
    );

    blocTest<ManagerEventsCubit, ManagerEventsState>(
      'loadEvents emite error cuando falla el repositorio',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(
          () => repository.fetchMyEvents('manager-1'),
        ).thenThrow(Exception('fetch error'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadEvents(),
      expect: () => [
        isA<ManagerEventsState>().having((s) => s.isLoading, 'loading', true),
        isA<ManagerEventsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('fetch error')),
      ],
    );

    // -- setFilter --

    blocTest<ManagerEventsCubit, ManagerEventsState>(
      'setFilter cambia el filtro activo',
      build: buildCubit,
      act: (cubit) => cubit.setFilter(ManagerEventFilter.upcoming),
      expect: () => [
        isA<ManagerEventsState>().having(
          (s) => s.filter,
          'filter',
          ManagerEventFilter.upcoming,
        ),
      ],
    );

    // -- deleteEvent --

    blocTest<ManagerEventsCubit, ManagerEventsState>(
      'deleteEvent elimina el evento y actualiza la lista',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(
          () => repository.fetchMyEvents('manager-1'),
        ).thenAnswer((_) async => events);
        when(() => repository.delete('e1')).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => ManagerEventsState(isLoading: false, events: events),
      act: (cubit) => cubit.deleteEvent('e1'),
      expect: () => [
        isA<ManagerEventsState>().having((s) => s.isLoading, 'loading', true),
        isA<ManagerEventsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.events.length, 'count', 1)
            .having((s) => s.events.first.id, 'remaining', 'e2'),
      ],
    );

    blocTest<ManagerEventsCubit, ManagerEventsState>(
      'deleteEvent emite error cuando falla la eliminación',
      build: () {
        when(
          () => repository.delete('e1'),
        ).thenThrow(Exception('delete failed'));
        return buildCubit();
      },
      seed: () => ManagerEventsState(isLoading: false, events: events),
      act: (cubit) => cubit.deleteEvent('e1'),
      expect: () => [
        isA<ManagerEventsState>().having((s) => s.isLoading, 'loading', true),
        isA<ManagerEventsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('delete failed')),
      ],
    );
  });
}
