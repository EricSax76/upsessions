import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/auth/data/auth_exceptions.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';
import 'package:upsessions/modules/auth/data/profile_dto.dart';
import 'package:upsessions/modules/auth/data/profile_repository.dart';
import 'package:upsessions/modules/auth/domain/profile_entity.dart';
import 'package:upsessions/modules/auth/domain/user_entity.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockProfileRepository profileRepository;
  late StreamController<UserEntity?> authChangesController;
  const user = UserEntity(
    id: 'test-uid',
    email: 'solista@example.com',
    displayName: 'Solista Demo',
    isVerified: true,
  );

  const profileDto = ProfileDto(
    id: 'test-uid',
    name: 'Solista Demo',
    bio: 'Bio demo',
    location: 'CDMX',
    skills: ['Guitarra'],
    links: {'instagram': '@demo'},
    photoUrl: 'https://example.com/photo.jpg',
  );
  const profileEntity = ProfileEntity(
    id: 'test-uid',
    name: 'Solista Demo',
    bio: 'Bio demo',
    location: 'CDMX',
    skills: ['Guitarra'],
    links: {'instagram': '@demo'},
    photoUrl: 'https://example.com/photo.jpg',
  );

  setUp(() {
    authRepository = _MockAuthRepository();
    profileRepository = _MockProfileRepository();
    authChangesController = StreamController<UserEntity?>.broadcast();
    when(
      () => authRepository.authStateChanges,
    ).thenAnswer((_) => authChangesController.stream);
    when(() => authRepository.currentUser).thenReturn(null);
    when(
      () => profileRepository.fetchProfile(profileId: any(named: 'profileId')),
    ).thenAnswer((_) async => profileDto);
  });

  tearDown(() async {
    await authChangesController.close();
  });

  group('AuthCubit', () {
    test('empieza desautenticado cuando no hay sesión activa', () {
      final cubit = AuthCubit(
        authRepository: authRepository,
        profileRepository: profileRepository,
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
          profileRepository: profileRepository,
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
          status: AuthStatus.authenticated,
          isLoading: false,
          errorMessage: null,
          passwordResetEmailSent: false,
          lastAction: AuthAction.none,
          user: user,
        ),
        AuthState(
          status: AuthStatus.authenticated,
          isLoading: true,
          errorMessage: null,
          passwordResetEmailSent: false,
          lastAction: AuthAction.loadProfile,
          user: user,
        ),
        AuthState(
          status: AuthStatus.authenticated,
          isLoading: false,
          errorMessage: null,
          passwordResetEmailSent: false,
          lastAction: AuthAction.none,
          user: user,
          profile: profileEntity,
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
          profileRepository: profileRepository,
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
