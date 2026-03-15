import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/venues/cubits/manager_venue_form_cubit.dart';
import 'package:upsessions/modules/venues/cubits/manager_venue_form_state.dart';
import 'package:upsessions/modules/venues/models/venue_entity.dart';
import 'package:upsessions/modules/venues/repositories/venues_repository.dart';

class _MockVenuesRepository extends Mock implements VenuesRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockVenuesRepository venuesRepository;
  late _MockAuthRepository authRepository;

  final user = UserEntity(
    id: 'manager-1',
    email: 'manager@test.com',
    displayName: 'Manager',
    createdAt: DateTime(2026, 1, 1),
  );

  final venue = VenueEntity(
    id: 'venue-1',
    ownerId: 'manager-1',
    name: 'Sala Centro',
    description: 'Descripción',
    address: 'Calle Centro',
    city: 'Madrid',
    province: 'Madrid',
    contactEmail: 'centro@test.com',
    contactPhone: '+34 600 000 100',
    licenseNumber: 'LIC-C',
    maxCapacity: 110,
    accessibilityInfo: 'PMR',
    isPublic: true,
  );

  setUpAll(() {
    registerFallbackValue(
      VenueEntity(
        id: '',
        ownerId: 'owner',
        name: 'fallback',
        description: 'fallback',
        address: 'fallback',
        city: 'fallback',
        province: 'fallback',
        contactEmail: 'fallback@test.com',
        contactPhone: '0',
        licenseNumber: 'fallback',
        maxCapacity: 1,
        accessibilityInfo: 'fallback',
      ),
    );
  });

  setUp(() {
    venuesRepository = _MockVenuesRepository();
    authRepository = _MockAuthRepository();
  });

  ManagerVenueFormCubit buildCubit() {
    return ManagerVenueFormCubit(
      venuesRepository: venuesRepository,
      authRepository: authRepository,
    );
  }

  test('initial state is idle and create-mode', () {
    final cubit = buildCubit();
    expect(cubit.state.isLoading, false);
    expect(cubit.state.isSaving, false);
    expect(cubit.state.isEditing, false);
    expect(cubit.state.isPublic, true);
    expect(cubit.state.feedbackMessage, isNull);
    cubit.close();
  });

  blocTest<ManagerVenueFormCubit, ManagerVenueFormState>(
    'initialize with initialVenue hydrates state and draft',
    build: buildCubit,
    act: (cubit) => cubit.initialize(initialVenue: venue),
    expect: () => [
      isA<ManagerVenueFormState>()
          .having((s) => s.isEditing, 'isEditing', true)
          .having((s) => s.isPublic, 'isPublic', true)
          .having((s) => s.editingVenue?.id, 'venueId', 'venue-1'),
    ],
    verify: (cubit) {
      expect(cubit.draft.nameController.text, venue.name);
      expect(cubit.draft.maxCapacityController.text, '110');
    },
  );

  blocTest<ManagerVenueFormCubit, ManagerVenueFormState>(
    'initialize loads venue by id when editing by route param',
    build: () {
      when(
        () => venuesRepository.getVenueById('venue-1'),
      ).thenAnswer((_) async => venue);
      return buildCubit();
    },
    act: (cubit) => cubit.initialize(venueId: 'venue-1'),
    expect: () => [
      isA<ManagerVenueFormState>().having(
        (s) => s.requestedVenueId,
        'requested id',
        'venue-1',
      ),
      isA<ManagerVenueFormState>().having((s) => s.isLoading, 'loading', true),
      isA<ManagerVenueFormState>()
          .having((s) => s.isLoading, 'loaded', false)
          .having((s) => s.isEditing, 'isEditing', true)
          .having((s) => s.loadingError, 'loadingError', isNull),
    ],
    verify: (cubit) {
      expect(cubit.draft.nameController.text, venue.name);
      verify(() => venuesRepository.getVenueById('venue-1')).called(1);
    },
  );

  blocTest<ManagerVenueFormCubit, ManagerVenueFormState>(
    'initialize sets loadingError when venue does not exist',
    build: () {
      when(
        () => venuesRepository.getVenueById('venue-404'),
      ).thenAnswer((_) async => null);
      return buildCubit();
    },
    act: (cubit) => cubit.initialize(venueId: 'venue-404'),
    expect: () => [
      isA<ManagerVenueFormState>().having(
        (s) => s.requestedVenueId,
        'requested id',
        'venue-404',
      ),
      isA<ManagerVenueFormState>().having((s) => s.isLoading, 'loading', true),
      isA<ManagerVenueFormState>()
          .having((s) => s.isLoading, 'loaded', false)
          .having(
            (s) => s.loadingError,
            'loadingError',
            contains('no encontrado'),
          ),
    ],
  );

  blocTest<ManagerVenueFormCubit, ManagerVenueFormState>(
    'saveVenue persists draft when authenticated',
    build: () {
      when(() => authRepository.currentUser).thenReturn(user);
      when(() => venuesRepository.saveDraft(any())).thenAnswer((
        invocation,
      ) async {
        final submitted = invocation.positionalArguments.single as VenueEntity;
        return submitted.copyWith(id: 'venue-new');
      });
      return buildCubit();
    },
    act: (cubit) async {
      cubit.draft.nameController.text = '  Nuevo Local  ';
      cubit.draft.descriptionController.text = 'Desc';
      cubit.draft.addressController.text = 'Calle 1';
      cubit.draft.cityController.text = 'Madrid';
      cubit.draft.provinceController.text = 'Madrid';
      cubit.draft.postalCodeController.text = ' 28001 ';
      cubit.draft.contactEmailController.text = ' venue@test.com ';
      cubit.draft.contactPhoneController.text = '+34 600 000 000';
      cubit.draft.licenseNumberController.text = 'LIC-NEW';
      cubit.draft.maxCapacityController.text = '120';
      cubit.draft.accessibilityInfoController.text = 'Ramp';
      cubit.setIsPublic(false);
      await cubit.saveVenue();
    },
    expect: () => [
      isA<ManagerVenueFormState>().having((s) => s.isPublic, 'isPublic', false),
      isA<ManagerVenueFormState>().having((s) => s.isSaving, 'saving', true),
      isA<ManagerVenueFormState>()
          .having((s) => s.isSaving, 'saved', false)
          .having((s) => s.saveSuccess, 'success', true)
          .having((s) => s.editingVenue?.id, 'new id', 'venue-new')
          .having((s) => s.requestedVenueId, 'requested id', 'venue-new'),
    ],
    verify: (_) {
      final saved =
          verify(() => venuesRepository.saveDraft(captureAny())).captured.single
              as VenueEntity;
      expect(saved.id, '');
      expect(saved.ownerId, 'manager-1');
      expect(saved.name, 'Nuevo Local');
      expect(saved.postalCode, '28001');
      expect(saved.contactEmail, 'venue@test.com');
      expect(saved.isPublic, false);
      expect(saved.maxCapacity, 120);
    },
  );

  blocTest<ManagerVenueFormCubit, ManagerVenueFormState>(
    'saveVenue emits feedback when user is not authenticated',
    build: () {
      when(() => authRepository.currentUser).thenReturn(null);
      return buildCubit();
    },
    act: (cubit) => cubit.saveVenue(),
    expect: () => [
      isA<ManagerVenueFormState>().having(
        (s) => s.feedbackMessage,
        'feedback',
        'Debes iniciar sesión para gestionar locales.',
      ),
    ],
    verify: (_) {
      verifyNever(() => venuesRepository.saveDraft(any()));
    },
  );

  blocTest<ManagerVenueFormCubit, ManagerVenueFormState>(
    'saveVenue blocks editing studio-backed venues',
    build: () {
      when(() => authRepository.currentUser).thenReturn(user);
      return buildCubit();
    },
    act: (cubit) async {
      final studioVenue = venue.copyWith(sourceType: VenueSourceType.studio);
      await cubit.initialize(initialVenue: studioVenue);
      await cubit.saveVenue();
    },
    expect: () => [
      isA<ManagerVenueFormState>().having(
        (s) => s.isEditing,
        'isEditing',
        true,
      ),
      isA<ManagerVenueFormState>().having(
        (s) => s.feedbackMessage,
        'feedback',
        'Este local viene de studios y no se edita desde aquí.',
      ),
    ],
    verify: (_) {
      verifyNever(() => venuesRepository.saveDraft(any()));
    },
  );
}
