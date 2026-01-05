import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/core/services/firebase_initializer.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';
import 'package:upsessions/modules/auth/domain/user_entity.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/home/cubits/bootstrap_cubit.dart';

class _MockFirebaseInitializer extends Mock implements FirebaseInitializer {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockMusiciansRepository extends Mock implements MusiciansRepository {}

void main() {
  late _MockFirebaseInitializer firebaseInitializer;
  late _MockAuthRepository authRepository;
  late _MockMusiciansRepository musiciansRepository;

  setUp(() {
    firebaseInitializer = _MockFirebaseInitializer();
    authRepository = _MockAuthRepository();
    musiciansRepository = _MockMusiciansRepository();
    when(() => firebaseInitializer.init()).thenAnswer((_) async {});
    when(() => authRepository.currentUser).thenReturn(null);
    when(
      () => musiciansRepository.hasProfile(any()),
    ).thenAnswer((_) async => false);
  });

  const storedUser = UserEntity(
    id: 'uid',
    email: 'demo@upsessions.com',
    displayName: 'Demo',
  );

  group('BootstrapCubit', () {
    blocTest<BootstrapCubit, BootstrapState>(
      'emite needsLogin cuando no existe una sesión',
      build: () => BootstrapCubit(
        firebaseInitializer: firebaseInitializer,
        authRepository: authRepository,
        musiciansRepository: musiciansRepository,
      ),
      act: (cubit) => cubit.initialize(),
      expect: () => const [
        BootstrapState(
          status: BootstrapStatus.loading,
          errorMessage: null,
          user: null,
        ),
        BootstrapState(
          status: BootstrapStatus.needsLogin,
          errorMessage: null,
          user: null,
        ),
      ],
      verify: (_) {
        verify(() => firebaseInitializer.init()).called(1);
        verify(() => authRepository.currentUser).called(1);
      },
    );

    blocTest<BootstrapCubit, BootstrapState>(
      'emite authenticated cuando hay usuario almacenado',
      build: () {
        when(() => authRepository.currentUser).thenReturn(storedUser);
        when(
          () => musiciansRepository.hasProfile(storedUser.id),
        ).thenAnswer((_) async => true);
        return BootstrapCubit(
          firebaseInitializer: firebaseInitializer,
          authRepository: authRepository,
          musiciansRepository: musiciansRepository,
        );
      },
      act: (cubit) => cubit.initialize(),
      expect: () => const [
        BootstrapState(
          status: BootstrapStatus.loading,
          errorMessage: null,
          user: null,
        ),
        BootstrapState(
          status: BootstrapStatus.authenticated,
          errorMessage: null,
          user: storedUser,
        ),
      ],
    );

    blocTest<BootstrapCubit, BootstrapState>(
      'propaga error cuando Firebase falla',
      build: () {
        when(
          () => firebaseInitializer.init(),
        ).thenThrow(Exception('network-failure'));
        return BootstrapCubit(
          firebaseInitializer: firebaseInitializer,
          authRepository: authRepository,
          musiciansRepository: musiciansRepository,
        );
      },
      act: (cubit) => cubit.initialize(),
      expect: () => const [
        BootstrapState(
          status: BootstrapStatus.loading,
          errorMessage: null,
          user: null,
        ),
        BootstrapState(
          status: BootstrapStatus.error,
          errorMessage: 'Exception: network-failure',
          user: null,
        ),
      ],
    );

    blocTest<BootstrapCubit, BootstrapState>(
      'emite needsOnboarding cuando falta el perfil',
      build: () {
        when(() => authRepository.currentUser).thenReturn(storedUser);
        when(
          () => musiciansRepository.hasProfile(storedUser.id),
        ).thenAnswer((_) async => false);
        return BootstrapCubit(
          firebaseInitializer: firebaseInitializer,
          authRepository: authRepository,
          musiciansRepository: musiciansRepository,
        );
      },
      act: (cubit) => cubit.initialize(),
      expect: () => const [
        BootstrapState(
          status: BootstrapStatus.loading,
          errorMessage: null,
          user: null,
        ),
        BootstrapState(
          status: BootstrapStatus.needsOnboarding,
          errorMessage: null,
          user: storedUser,
        ),
      ],
    );
  });
}
