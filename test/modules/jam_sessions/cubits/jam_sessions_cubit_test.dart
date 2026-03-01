import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/jam_sessions/cubits/jam_sessions_cubit.dart';
import 'package:upsessions/modules/jam_sessions/cubits/jam_sessions_state.dart';
import 'package:upsessions/modules/jam_sessions/models/jam_session_entity.dart';
import 'package:upsessions/modules/jam_sessions/repositories/jam_sessions_repository.dart';

class _MockJamSessionsRepository extends Mock
    implements JamSessionsRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockJamSessionsRepository repository;
  late _MockAuthRepository authRepository;

  const user = UserEntity(
    id: 'manager-1',
    email: 'mgr@test.com',
    displayName: 'Mgr',
  );

  final sessions = [
    JamSessionEntity(
      id: 'js1',
      ownerId: 'manager-1',
      title: 'Jazz Jam Night',
      description: 'Open jazz jam',
      date: DateTime(2026, 4, 10),
      time: '20:00',
      location: 'Café Central',
      city: 'Madrid',
      instrumentRequirements: const ['Saxofón', 'Piano'],
    ),
    JamSessionEntity(
      id: 'js2',
      ownerId: 'manager-1',
      title: 'Blues Open Mic',
      description: 'Open blues session',
      date: DateTime(2026, 4, 15),
      time: '21:00',
      location: 'Bar Blues',
      city: 'Barcelona',
    ),
  ];

  setUp(() {
    repository = _MockJamSessionsRepository();
    authRepository = _MockAuthRepository();
  });

  JamSessionsCubit buildCubit() {
    return JamSessionsCubit(
      repository: repository,
      authRepository: authRepository,
    );
  }

  group('JamSessionsCubit', () {
    test('estado inicial tiene isLoading true, filtro upcoming y lista vacía', () {
      final cubit = buildCubit();
      expect(cubit.state.isLoading, true);
      expect(cubit.state.sessions, isEmpty);
      expect(cubit.state.filter, JamSessionFilter.upcoming);
      expect(cubit.state.errorMessage, isNull);
      cubit.close();
    });

    // -- loadSessions --

    blocTest<JamSessionsCubit, JamSessionsState>(
      'loadSessions carga las jam sessions del manager',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(() => repository.fetchMySessions('manager-1'))
            .thenAnswer((_) async => sessions);
        return buildCubit();
      },
      act: (cubit) => cubit.loadSessions(),
      expect: () => [
        isA<JamSessionsState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<JamSessionsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.sessions.length, 'count', 2),
      ],
    );

    blocTest<JamSessionsCubit, JamSessionsState>(
      'loadSessions emite error cuando no hay usuario autenticado',
      build: () {
        when(() => authRepository.currentUser).thenReturn(null);
        return buildCubit();
      },
      act: (cubit) => cubit.loadSessions(),
      expect: () => [
        isA<JamSessionsState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<JamSessionsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('No autenticado')),
      ],
    );

    blocTest<JamSessionsCubit, JamSessionsState>(
      'loadSessions emite error cuando falla el repositorio',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(() => repository.fetchMySessions('manager-1'))
            .thenThrow(Exception('fetch error'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadSessions(),
      expect: () => [
        isA<JamSessionsState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<JamSessionsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('fetch error')),
      ],
    );

    // -- setFilter --

    blocTest<JamSessionsCubit, JamSessionsState>(
      'setFilter cambia el filtro activo',
      build: buildCubit,
      act: (cubit) => cubit.setFilter(JamSessionFilter.past),
      expect: () => [
        isA<JamSessionsState>()
            .having((s) => s.filter, 'filter', JamSessionFilter.past),
      ],
    );

    blocTest<JamSessionsCubit, JamSessionsState>(
      'setFilter a all muestra todas las sesiones',
      build: buildCubit,
      act: (cubit) => cubit.setFilter(JamSessionFilter.all),
      expect: () => [
        isA<JamSessionsState>()
            .having((s) => s.filter, 'filter', JamSessionFilter.all),
      ],
    );

    // -- deleteSession --

    blocTest<JamSessionsCubit, JamSessionsState>(
      'deleteSession elimina la sesión y actualiza la lista',
      build: () {
        when(() => repository.delete('js1')).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => JamSessionsState(isLoading: false, sessions: sessions),
      act: (cubit) => cubit.deleteSession('js1'),
      expect: () => [
        isA<JamSessionsState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<JamSessionsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.sessions.length, 'count', 1)
            .having((s) => s.sessions.first.id, 'remaining', 'js2'),
      ],
    );

    blocTest<JamSessionsCubit, JamSessionsState>(
      'deleteSession emite error cuando falla la eliminación',
      build: () {
        when(() => repository.delete('js1'))
            .thenThrow(Exception('delete error'));
        return buildCubit();
      },
      seed: () => JamSessionsState(isLoading: false, sessions: sessions),
      act: (cubit) => cubit.deleteSession('js1'),
      expect: () => [
        isA<JamSessionsState>()
            .having((s) => s.isLoading, 'loading', true),
        isA<JamSessionsState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'err', contains('delete error')),
      ],
    );
  });
}
