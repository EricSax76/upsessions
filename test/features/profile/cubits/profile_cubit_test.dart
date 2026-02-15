import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/auth/models/profile_dto.dart';
import 'package:upsessions/modules/auth/repositories/profile_repository.dart';
import 'package:upsessions/modules/auth/models/profile_entity.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';
import 'package:upsessions/core/services/push_notifications_service.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockProfileRepository extends Mock implements ProfileRepository {}
class _MockStudiosRepository extends Mock implements StudiosRepository {}
class _MockPushNotificationsService extends Mock implements PushNotificationsService {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockProfileRepository profileRepository;
  late _MockStudiosRepository studiosRepository;
  late _MockPushNotificationsService pushNotificationsService;
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
    bio: 'Bio',
    location: 'Madrid',
    skills: ['rock'],
    links: {'instagram': 'https://instagram.com/solista'},
    photoUrl: null,
  );

  const profileEntity = ProfileEntity(
    id: 'test-uid',
    name: 'Solista Demo',
    bio: 'Bio',
    location: 'Madrid',
    skills: ['rock'],
    links: {'instagram': 'https://instagram.com/solista'},
    photoUrl: null,
  );

  setUpAll(() {
    registerFallbackValue(user);
  });

  setUp(() {
    authRepository = _MockAuthRepository();
    profileRepository = _MockProfileRepository();
    studiosRepository = _MockStudiosRepository();
    pushNotificationsService = _MockPushNotificationsService();
    authChangesController = StreamController<UserEntity?>.broadcast();

    when(
      () => authRepository.authStateChanges,
    ).thenAnswer((_) => authChangesController.stream);
    when(() => authRepository.currentUser).thenReturn(null);
    when(
      () => profileRepository.fetchProfile(profileId: any(named: 'profileId')),
    ).thenAnswer((_) async => profileDto);
    when(
      () => studiosRepository.getStudioByOwner(any()),
    ).thenAnswer((_) async => null);
    when(() => pushNotificationsService.registerForUser(any())).thenAnswer((_) async {});
    when(() => pushNotificationsService.unregisterUser(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await authChangesController.close();
  });

  group('ProfileCubit', () {
    blocTest<ProfileCubit, ProfileState>(
      'carga el perfil si el usuario ya está autenticado al crearse',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        final authCubit = AuthCubit(
          authRepository: authRepository, 
          studiosRepository: studiosRepository,
          pushNotificationsService: pushNotificationsService,
        );
        addTearDown(authCubit.close);
        return ProfileCubit(
          profileRepository: profileRepository,
          authCubit: authCubit,
        );
      },
      wait: const Duration(milliseconds: 1),
      verify: (_) {
        verify(
          () => profileRepository.fetchProfile(profileId: user.id),
        ).called(1);
      },
      expect: () => const [
        ProfileState(status: ProfileStatus.loading),
        ProfileState(status: ProfileStatus.success, profile: profileEntity),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'carga el perfil cuando AuthCubit emite un usuario después del login',
      build: () {
        final authCubit = AuthCubit(
          authRepository: authRepository, 
          studiosRepository: studiosRepository,
          pushNotificationsService: pushNotificationsService,
        );
        addTearDown(authCubit.close);
        return ProfileCubit(
          profileRepository: profileRepository,
          authCubit: authCubit,
        );
      },
      act: (_) async {
        authChangesController.add(user);
      },
      wait: const Duration(milliseconds: 1),
      verify: (_) {
        verify(
          () => profileRepository.fetchProfile(profileId: user.id),
        ).called(1);
      },
      expect: () => const [
        ProfileState(status: ProfileStatus.loading),
        ProfileState(status: ProfileStatus.success, profile: profileEntity),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'limpia el perfil cuando el usuario cierra sesión',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        final authCubit = AuthCubit(
          authRepository: authRepository, 
          studiosRepository: studiosRepository,
          pushNotificationsService: pushNotificationsService,
        );
        addTearDown(authCubit.close);
        return ProfileCubit(
          profileRepository: profileRepository,
          authCubit: authCubit,
        );
      },
      act: (_) async {
        authChangesController.add(null);
      },
      wait: const Duration(milliseconds: 1),
      expect: () => const [
        ProfileState(status: ProfileStatus.loading),
        ProfileState(status: ProfileStatus.success, profile: profileEntity),
        ProfileState(),
      ],
    );
  });
}
