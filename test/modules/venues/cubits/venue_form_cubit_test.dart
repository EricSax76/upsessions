import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/venues/cubits/venue_form_cubit.dart';
import 'package:upsessions/modules/venues/cubits/venue_form_state.dart';
import 'package:upsessions/modules/venues/models/venue_entity.dart';
import 'package:upsessions/modules/venues/repositories/venues_repository.dart';

class _MockVenuesRepository extends Mock implements VenuesRepository {}

void main() {
  late _MockVenuesRepository venuesRepository;

  final venue = VenueEntity(
    id: '',
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
  );

  setUp(() {
    venuesRepository = _MockVenuesRepository();
  });

  VenueFormCubit buildCubit() {
    return VenueFormCubit(venuesRepository: venuesRepository);
  }

  test('initial state is idle', () {
    final cubit = buildCubit();
    expect(cubit.state.isSaving, false);
    expect(cubit.state.success, false);
    expect(cubit.state.errorMessage, isNull);
    cubit.close();
  });

  blocTest<VenueFormCubit, VenueFormState>(
    'saveVenue emits success when repository succeeds',
    build: () {
      when(
        () => venuesRepository.saveDraft(venue),
      ).thenAnswer((_) async => venue);
      return buildCubit();
    },
    act: (cubit) => cubit.saveVenue(venue),
    expect: () => [
      isA<VenueFormState>().having((s) => s.isSaving, 'saving', true),
      isA<VenueFormState>()
          .having((s) => s.isSaving, 'saved', false)
          .having((s) => s.success, 'success', true),
    ],
  );

  blocTest<VenueFormCubit, VenueFormState>(
    'saveVenue emits error when repository fails',
    build: () {
      when(
        () => venuesRepository.saveDraft(venue),
      ).thenThrow(Exception('boom'));
      return buildCubit();
    },
    act: (cubit) => cubit.saveVenue(venue),
    expect: () => [
      isA<VenueFormState>().having((s) => s.isSaving, 'saving', true),
      isA<VenueFormState>()
          .having((s) => s.isSaving, 'saved', false)
          .having((s) => s.success, 'success', false)
          .having((s) => s.errorMessage, 'error', contains('boom')),
    ],
  );
}
