import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/auth/models/auth_exceptions.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';
import 'package:upsessions/core/services/push_notifications_service.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}
class _MockStudiosRepository extends Mock implements StudiosRepository {}
class _MockPushNotificationsService extends Mock implements PushNotificationsService {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockStudiosRepository studiosRepository;
  late _MockPushNotificationsService pushNotificationsService;
  late StreamController<UserEntity?> authChangesController;
  const user = UserEntity(
    id: 'test-uid',
    email: 'solista@example.com',
    displayName: 'Solista Demo',
    isVerified: true,
  );

  setUpAll(() {
    registerFallbackValue(user);
  });

  setUp(() {
    authRepository = _MockAuthRepository();
    studiosRepository = _MockStudiosRepository();
    pushNotificationsService = _MockPushNotificationsService();
    authChangesController = StreamController<UserEntity?>.broadcast();
    when(
      () => authRepository.authStateChanges,
    ).thenAnswer((_) => authChangesController.stream);
    when(() => authRepository.currentUser).thenReturn(null);
    when(
      () => studiosRepository.getStudioByOwner(any()),
    ).thenAnswer((_) async => null);
    when(() => pushNotificationsService.registerForUser(any())).thenAnswer((_) async {});
    when(() => pushNotificationsService.unregisterUser(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await authChangesController.close();
  });

  group('AuthCubit', () {
    test('empieza desautenticado cuando no hay sesión activa', () {
      final cubit = AuthCubit(
        authRepository: authRepository, 
        studiosRepository: studiosRepository,
        pushNotificationsService: pushNotificationsService,
      );
      expect(cubit.state.status, AuthStatus.unauthenticated);
      cubit.close();
    });

    blocTest<AuthCubit, AuthState>(
      'signIn emite loading, autentica y carga el perfil',
      build: () {
        when(() => authRepository.signIn(any(), any())).thenAnswer((
          invocation,
        ) async {
          authChangesController.add(user);
          return user;
        });
        return AuthCubit(
          authRepository: authRepository, 
          studiosRepository: studiosRepository,
          pushNotificationsService: pushNotificationsService,
        );
      },
      act: (cubit) => cubit.signIn('solista@example.com', 'token'),
      expect: () => const [
        AuthState(
          status: AuthStatus.unauthenticated,
          isLoading: true,
          errorMessage: null,
          passwordResetEmailSent: false,
          lastAction: AuthAction.login,
        ),
        AuthState(
          status: AuthStatus.unauthenticated,
          isLoading: false,
          errorMessage: null,
          passwordResetEmailSent: false,
          lastAction: AuthAction.login,
        ),
        AuthState(
          status: AuthStatus.authenticated,
          isLoading: false,
          errorMessage: null,
          passwordResetEmailSent: false,
          lastAction: AuthAction.none,
          user: user,
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'signIn publica error cuando las credenciales son inválidas',
      build: () {
        when(
          () => authRepository.signIn(any(), any()),
        ).thenThrow(InvalidCredentialsException());
        return AuthCubit(
          authRepository: authRepository, 
          studiosRepository: studiosRepository,
          pushNotificationsService: pushNotificationsService,
        );
      },
      act: (cubit) => cubit.signIn('invalid@example.com', 'wrong'),
      expect: () => const [
        AuthState(
          status: AuthStatus.unauthenticated,
          isLoading: true,
          errorMessage: null,
          passwordResetEmailSent: false,
          lastAction: AuthAction.login,
        ),
        AuthState(
          status: AuthStatus.unauthenticated,
          isLoading: false,
          errorMessage: 'Las credenciales no son válidas.',
          passwordResetEmailSent: false,
          lastAction: AuthAction.login,
        ),
      ],
    );
  });
}
