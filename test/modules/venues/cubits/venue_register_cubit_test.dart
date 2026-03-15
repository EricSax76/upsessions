import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/event_manager/models/event_manager_entity.dart';
import 'package:upsessions/modules/event_manager/repositories/event_manager_repository.dart';
import 'package:upsessions/modules/venues/cubits/venue_register_cubit.dart';
import 'package:upsessions/modules/venues/cubits/venue_register_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockEventManagerRepository extends Mock
    implements EventManagerRepository {}

void main() {
  late _MockAuthRepository authRepository;
  late _MockEventManagerRepository managerRepository;

  final user = UserEntity(
    id: 'user-1',
    email: 'venue@test.com',
    displayName: 'Sala Centro',
    createdAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      const EventManagerEntity(
        id: 'fallback',
        ownerId: 'fallback',
        name: 'fallback',
        contactEmail: 'fallback@test.com',
        contactPhone: '0',
        city: 'fallback',
        specialties: ['venues'],
      ),
    );
  });

  setUp(() {
    authRepository = _MockAuthRepository();
    managerRepository = _MockEventManagerRepository();
  });

  VenueRegisterCubit buildCubit() {
    return VenueRegisterCubit(
      authRepository: authRepository,
      managerRepository: managerRepository,
    );
  }

  test('initial state is idle with password obscured', () {
    final cubit = buildCubit();
    expect(cubit.state.status, VenueRegisterStatus.initial);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.obscurePassword, isTrue);
    cubit.close();
  });

  blocTest<VenueRegisterCubit, VenueRegisterState>(
    'togglePasswordVisibility toggles obscurePassword flag',
    build: buildCubit,
    act: (cubit) {
      cubit.togglePasswordVisibility();
      cubit.togglePasswordVisibility();
    },
    expect: () => [
      isA<VenueRegisterState>().having(
        (s) => s.obscurePassword,
        'visible',
        false,
      ),
      isA<VenueRegisterState>().having(
        (s) => s.obscurePassword,
        'hidden',
        true,
      ),
    ],
  );

  blocTest<VenueRegisterCubit, VenueRegisterState>(
    'register emits success and creates manager profile for venues',
    build: () {
      when(
        () => authRepository.register(
          email: 'venue@test.com',
          password: 'secret123',
          displayName: 'Sala Centro',
        ),
      ).thenAnswer((_) async => user);
      when(() => managerRepository.create(any())).thenAnswer((_) async {});
      return buildCubit();
    },
    act: (cubit) async {
      cubit.draft.emailController.text = '  venue@test.com  ';
      cubit.draft.passwordController.text = 'secret123';
      cubit.draft.venueNameController.text = '  Sala Centro  ';
      cubit.draft.contactPhoneController.text = '+34 600 000 000';
      cubit.draft.cityController.text = '  Madrid ';
      cubit.draft.websiteController.text = '   ';
      await cubit.register();
    },
    expect: () => [
      isA<VenueRegisterState>().having(
        (s) => s.status,
        'submitting',
        VenueRegisterStatus.submitting,
      ),
      isA<VenueRegisterState>().having(
        (s) => s.status,
        'success',
        VenueRegisterStatus.success,
      ),
    ],
    verify: (_) {
      final created =
          verify(() => managerRepository.create(captureAny())).captured.single
              as EventManagerEntity;
      expect(created.id, 'user-1');
      expect(created.ownerId, 'user-1');
      expect(created.name, 'Sala Centro');
      expect(created.contactEmail, 'venue@test.com');
      expect(created.contactPhone, '+34 600 000 000');
      expect(created.city, 'Madrid');
      expect(created.website, isNull);
      expect(created.specialties, const ['venues']);
    },
  );

  blocTest<VenueRegisterCubit, VenueRegisterState>(
    'register emits failure when auth registration fails',
    build: () {
      when(
        () => authRepository.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
        ),
      ).thenThrow(Exception('email in use'));
      return buildCubit();
    },
    act: (cubit) async {
      cubit.draft.emailController.text = 'venue@test.com';
      cubit.draft.passwordController.text = 'secret123';
      cubit.draft.venueNameController.text = 'Sala Centro';
      cubit.draft.contactPhoneController.text = '+34 600 000 000';
      cubit.draft.cityController.text = 'Madrid';
      await cubit.register();
    },
    expect: () => [
      isA<VenueRegisterState>().having(
        (s) => s.status,
        'submitting',
        VenueRegisterStatus.submitting,
      ),
      isA<VenueRegisterState>()
          .having((s) => s.status, 'failure', VenueRegisterStatus.failure)
          .having((s) => s.errorMessage, 'error', contains('email in use')),
    ],
    verify: (_) {
      verifyNever(() => managerRepository.create(any()));
    },
  );

  blocTest<VenueRegisterCubit, VenueRegisterState>(
    'clearError resets failure state to initial without message',
    build: buildCubit,
    seed: () => const VenueRegisterState(
      status: VenueRegisterStatus.failure,
      errorMessage: 'boom',
    ),
    act: (cubit) => cubit.clearError(),
    expect: () => [
      isA<VenueRegisterState>()
          .having((s) => s.status, 'status', VenueRegisterStatus.initial)
          .having((s) => s.errorMessage, 'errorMessage', isNull),
    ],
  );
}
