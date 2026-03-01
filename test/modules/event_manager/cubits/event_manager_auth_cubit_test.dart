import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/event_manager/cubits/event_manager_auth_cubit.dart';
import 'package:upsessions/modules/event_manager/cubits/event_manager_auth_state.dart';
import 'package:upsessions/modules/event_manager/models/event_manager_entity.dart';
import 'package:upsessions/modules/event_manager/repositories/event_manager_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockEventManagerRepository extends Mock
    implements EventManagerRepository {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockEventManagerRepository managerRepository;

  const user = UserEntity(
    id: 'user-1',
    email: 'manager@test.com',
    displayName: 'Test Manager',
  );

  const manager = EventManagerEntity(
    id: 'user-1',
    ownerId: 'user-1',
    name: 'Test Manager',
    contactEmail: 'manager@test.com',
    contactPhone: '600123456',
    city: 'Madrid',
    specialties: ['Rock', 'Jazz'],
  );

  setUpAll(() {
    registerFallbackValue(manager);
  });

  setUp(() {
    authRepository = _MockAuthRepository();
    managerRepository = _MockEventManagerRepository();
  });

  EventManagerAuthCubit buildCubit() {
    return EventManagerAuthCubit(
      authRepository: authRepository,
      managerRepository: managerRepository,
    );
  }

  group('EventManagerAuthCubit', () {
    test('estado inicial es initial', () {
      final cubit = buildCubit();
      expect(cubit.state.status, EventManagerAuthStatus.initial);
      expect(cubit.state.manager, isNull);
      expect(cubit.state.errorMessage, isNull);
      cubit.close();
    });

    // -- loadProfile --

    blocTest<EventManagerAuthCubit, EventManagerAuthState>(
      'loadProfile emite authenticated cuando existe perfil de manager',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(() => managerRepository.fetchByOwnerId('user-1'))
            .thenAnswer((_) async => manager);
        return buildCubit();
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'loading', EventManagerAuthStatus.loading),
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'auth', EventManagerAuthStatus.authenticated)
            .having((s) => s.manager, 'manager', manager),
      ],
    );

    blocTest<EventManagerAuthCubit, EventManagerAuthState>(
      'loadProfile emite unauthenticated cuando no hay usuario logueado',
      build: () {
        when(() => authRepository.currentUser).thenReturn(null);
        return buildCubit();
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'loading', EventManagerAuthStatus.loading),
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'unauth', EventManagerAuthStatus.unauthenticated),
      ],
    );

    blocTest<EventManagerAuthCubit, EventManagerAuthState>(
      'loadProfile emite unauthenticated cuando no existe perfil de manager',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(() => managerRepository.fetchByOwnerId('user-1'))
            .thenAnswer((_) async => null);
        return buildCubit();
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'loading', EventManagerAuthStatus.loading),
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'unauth', EventManagerAuthStatus.unauthenticated),
      ],
    );

    blocTest<EventManagerAuthCubit, EventManagerAuthState>(
      'loadProfile emite error cuando falla el repositorio',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(() => managerRepository.fetchByOwnerId('user-1'))
            .thenThrow(Exception('network error'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'loading', EventManagerAuthStatus.loading),
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'error', EventManagerAuthStatus.error)
            .having((s) => s.errorMessage, 'msg', contains('network error')),
      ],
    );

    // -- login --

    blocTest<EventManagerAuthCubit, EventManagerAuthState>(
      'login autentica y carga el perfil del manager',
      build: () {
        when(() => authRepository.signIn('a@b.com', '123456'))
            .thenAnswer((_) async => user);
        when(() => authRepository.currentUser).thenReturn(user);
        when(() => managerRepository.fetchByOwnerId('user-1'))
            .thenAnswer((_) async => manager);
        return buildCubit();
      },
      act: (cubit) => cubit.login('a@b.com', '123456'),
      expect: () => [
        // login + loadProfile both emit loading, but bloc suppresses duplicates
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'loading', EventManagerAuthStatus.loading),
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'auth', EventManagerAuthStatus.authenticated)
            .having((s) => s.manager, 'manager', manager),
      ],
    );

    blocTest<EventManagerAuthCubit, EventManagerAuthState>(
      'login emite error cuando signIn falla',
      build: () {
        when(() => authRepository.signIn('a@b.com', 'wrong'))
            .thenThrow(Exception('invalid credentials'));
        return buildCubit();
      },
      act: (cubit) => cubit.login('a@b.com', 'wrong'),
      expect: () => [
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'loading', EventManagerAuthStatus.loading),
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'error', EventManagerAuthStatus.error)
            .having((s) => s.errorMessage, 'msg', contains('invalid credentials')),
      ],
    );

    // -- register --

    blocTest<EventManagerAuthCubit, EventManagerAuthState>(
      'register crea usuario, guarda perfil y emite authenticated',
      build: () {
        when(() => authRepository.register(
              email: 'new@test.com',
              password: 'pass123',
              displayName: 'New Manager',
            )).thenAnswer((_) async => user);
        when(() => managerRepository.create(any())).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) => cubit.register(
        email: 'new@test.com',
        password: 'pass123',
        managerName: 'New Manager',
        contactEmail: 'new@test.com',
        contactPhone: '600000000',
        city: 'Barcelona',
        specialties: ['Pop'],
      ),
      expect: () => [
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'loading', EventManagerAuthStatus.loading),
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'auth', EventManagerAuthStatus.authenticated)
            .having((s) => s.manager, 'has manager', isNotNull),
      ],
      verify: (_) {
        verify(() => managerRepository.create(any())).called(1);
      },
    );

    blocTest<EventManagerAuthCubit, EventManagerAuthState>(
      'register emite error cuando falla la creación',
      build: () {
        when(() => authRepository.register(
              email: 'new@test.com',
              password: 'pass123',
              displayName: 'New Manager',
            )).thenThrow(Exception('email in use'));
        return buildCubit();
      },
      act: (cubit) => cubit.register(
        email: 'new@test.com',
        password: 'pass123',
        managerName: 'New Manager',
        contactEmail: 'new@test.com',
        contactPhone: '600000000',
        city: 'Barcelona',
        specialties: ['Pop'],
      ),
      expect: () => [
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'loading', EventManagerAuthStatus.loading),
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'error', EventManagerAuthStatus.error)
            .having((s) => s.errorMessage, 'msg', contains('email in use')),
      ],
    );

    // -- logout --

    blocTest<EventManagerAuthCubit, EventManagerAuthState>(
      'logout emite loading y luego unauthenticated',
      build: () {
        when(() => authRepository.signOut()).thenAnswer((_) async {});
        return buildCubit();
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'loading', EventManagerAuthStatus.loading),
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'unauth', EventManagerAuthStatus.unauthenticated),
      ],
    );

    blocTest<EventManagerAuthCubit, EventManagerAuthState>(
      'logout emite error cuando signOut falla',
      build: () {
        when(() => authRepository.signOut())
            .thenThrow(Exception('sign out error'));
        return buildCubit();
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'loading', EventManagerAuthStatus.loading),
        isA<EventManagerAuthState>()
            .having((s) => s.status, 'error', EventManagerAuthStatus.error)
            .having((s) => s.errorMessage, 'msg', contains('sign out error')),
      ],
    );
  });
}
