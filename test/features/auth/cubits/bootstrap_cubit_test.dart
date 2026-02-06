import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/core/services/firebase_initializer.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/modules/studios/models/studio_entity.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';
import 'package:upsessions/home/cubits/bootstrap_cubit.dart';

class _MockFirebaseInitializer extends Mock implements FirebaseInitializer {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockMusiciansRepository extends Mock implements MusiciansRepository {}
class _MockStudiosRepository extends Mock implements StudiosRepository {}

void main() {
  late _MockFirebaseInitializer firebaseInitializer;
  late _MockAuthRepository authRepository;
  late _MockMusiciansRepository musiciansRepository;
  late _MockStudiosRepository studiosRepository;

  setUp(() {
    firebaseInitializer = _MockFirebaseInitializer();
    authRepository = _MockAuthRepository();
    musiciansRepository = _MockMusiciansRepository();
    studiosRepository = _MockStudiosRepository();
    when(() => firebaseInitializer.init()).thenAnswer((_) async {});
    when(() => authRepository.currentUser).thenReturn(null);
    when(
      () => musiciansRepository.hasProfile(any()),
    ).thenAnswer((_) async => false);
    when(
      () => studiosRepository.getStudioByOwner(any()),
    ).thenAnswer((_) async => null);
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
        studiosRepository: studiosRepository,
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
          studiosRepository: studiosRepository,
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
          studiosRepository: studiosRepository,
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
          studiosRepository: studiosRepository,
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

    blocTest<BootstrapCubit, BootstrapState>(
      'emite studioAuthenticated cuando hay estudio asociado',
      build: () {
        when(() => authRepository.currentUser).thenReturn(storedUser);
        when(() => studiosRepository.getStudioByOwner(storedUser.id)).thenAnswer(
          (_) async => const StudioEntity(
            id: 'studio-1',
            ownerId: 'uid',
            name: 'Studio Demo',
            description: 'Test studio',
            address: 'Street 1',
            contactEmail: 'studio@demo.com',
            contactPhone: '123',
            cif: 'CIF1',
            businessName: 'Studio Demo SL',
          ),
        );
        return BootstrapCubit(
          firebaseInitializer: firebaseInitializer,
          authRepository: authRepository,
          musiciansRepository: musiciansRepository,
          studiosRepository: studiosRepository,
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
          status: BootstrapStatus.studioAuthenticated,
          errorMessage: null,
          user: storedUser,
        ),
      ],
    );
  });
}
