import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/venues/cubits/venues_catalog_cubit.dart';
import 'package:upsessions/modules/venues/cubits/venues_catalog_state.dart';
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
    createdAt: DateTime.now(),
  );

  final venues = [
    VenueEntity(
      id: 'v-1',
      ownerId: 'manager-1',
      name: 'Sala Central',
      description: 'Local principal',
      address: 'Calle A 12',
      city: 'Madrid',
      province: 'Madrid',
      contactEmail: 'sala@test.com',
      contactPhone: '+34 600 111 222',
      licenseNumber: 'LIC-1',
      maxCapacity: 120,
      accessibilityInfo: 'Acceso PMR',
      isPublic: true,
      isActive: true,
    ),
  ];

  setUp(() {
    venuesRepository = _MockVenuesRepository();
    authRepository = _MockAuthRepository();
  });

  VenuesCatalogCubit buildCubit() {
    return VenuesCatalogCubit(
      venuesRepository: venuesRepository,
      authRepository: authRepository,
    );
  }

  group('VenuesCatalogCubit', () {
    test('initial state is empty and idle', () {
      final cubit = buildCubit();
      expect(cubit.state.venues, isEmpty);
      expect(cubit.state.isLoading, false);
      expect(cubit.state.errorMessage, isNull);
      cubit.close();
    });

    blocTest<VenuesCatalogCubit, VenuesCatalogState>(
      'loadSelectableVenues emits loaded venues',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(
          () => venuesRepository.getSelectableVenues(ownerId: 'manager-1'),
        ).thenAnswer((_) async => venues);
        return buildCubit();
      },
      act: (cubit) => cubit.loadSelectableVenues(),
      expect: () => [
        isA<VenuesCatalogState>().having((s) => s.isLoading, 'loading', true),
        isA<VenuesCatalogState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.venues.length, 'count', 1),
      ],
    );

    blocTest<VenuesCatalogCubit, VenuesCatalogState>(
      'loadSelectableVenues emits error when unauthenticated',
      build: () {
        when(() => authRepository.currentUser).thenReturn(null);
        return buildCubit();
      },
      act: (cubit) => cubit.loadSelectableVenues(),
      expect: () => [
        isA<VenuesCatalogState>().having((s) => s.isLoading, 'loading', true),
        isA<VenuesCatalogState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'error', contains('No autenticado')),
      ],
    );

    blocTest<VenuesCatalogCubit, VenuesCatalogState>(
      'loadSelectableVenues emits repository error',
      build: () {
        when(() => authRepository.currentUser).thenReturn(user);
        when(
          () => venuesRepository.getSelectableVenues(ownerId: 'manager-1'),
        ).thenThrow(Exception('venues failure'));
        return buildCubit();
      },
      act: (cubit) => cubit.loadSelectableVenues(),
      expect: () => [
        isA<VenuesCatalogState>().having((s) => s.isLoading, 'loading', true),
        isA<VenuesCatalogState>()
            .having((s) => s.isLoading, 'idle', false)
            .having((s) => s.errorMessage, 'error', contains('venues failure')),
      ],
    );
  });
}
