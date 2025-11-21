import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/core/services/firebase_initializer.dart';
import 'package:upsessions/features/auth/data/auth_repository.dart';
import 'package:upsessions/features/auth/domain/user_entity.dart';
import 'package:upsessions/features/splash/application/bootstrap_cubit.dart';

class _MockFirebaseInitializer extends Mock implements FirebaseInitializer {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockFirebaseInitializer firebaseInitializer;
  late _MockAuthRepository authRepository;

  setUp(() {
    firebaseInitializer = _MockFirebaseInitializer();
    authRepository = _MockAuthRepository();
    when(() => firebaseInitializer.init()).thenAnswer((_) async {});
    when(() => authRepository.currentUser).thenReturn(null);
  });

  const storedUser = UserEntity(id: 'uid', email: 'demo@upsessions.com', displayName: 'Demo');

  group('BootstrapCubit', () {
    blocTest<BootstrapCubit, BootstrapState>(
      'emite needsLogin cuando no existe una sesión',
      build: () => BootstrapCubit(firebaseInitializer: firebaseInitializer, authRepository: authRepository),
      act: (cubit) => cubit.initialize(),
      expect: () => const [
        BootstrapState(status: BootstrapStatus.loading, errorMessage: null, user: null),
        BootstrapState(status: BootstrapStatus.needsLogin, errorMessage: null, user: null),
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
        return BootstrapCubit(firebaseInitializer: firebaseInitializer, authRepository: authRepository);
      },
      act: (cubit) => cubit.initialize(),
      expect: () => const [
        BootstrapState(status: BootstrapStatus.loading, errorMessage: null, user: null),
        BootstrapState(status: BootstrapStatus.authenticated, errorMessage: null, user: storedUser),
      ],
    );

    blocTest<BootstrapCubit, BootstrapState>(
      'propaga error cuando Firebase falla',
      build: () {
        when(() => firebaseInitializer.init()).thenThrow(Exception('network-failure'));
        return BootstrapCubit(firebaseInitializer: firebaseInitializer, authRepository: authRepository);
      },
      act: (cubit) => cubit.initialize(),
      expect: () => const [
        BootstrapState(status: BootstrapStatus.loading, errorMessage: null, user: null),
        BootstrapState(status: BootstrapStatus.error, errorMessage: 'Exception: network-failure', user: null),
      ],
    );
  });
}
