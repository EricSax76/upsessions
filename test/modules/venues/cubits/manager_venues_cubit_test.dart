import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/venues/cubits/manager_venues_cubit.dart';
import 'package:upsessions/modules/venues/cubits/manager_venues_state.dart';
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

  final venue1 = VenueEntity(
    id: 'v-1',
    ownerId: 'manager-1',
    name: 'Sala Uno',
    description: 'Principal',
    address: 'Calle A',
    city: 'Madrid',
    province: 'Madrid',
    contactEmail: 'a@test.com',
    contactPhone: '+34 600 000 001',
    licenseNumber: 'LIC-1',
    maxCapacity: 100,
    accessibilityInfo: 'PMR',
  );

  final venue2 = VenueEntity(
    id: 'v-2',
    ownerId: 'manager-1',
    name: 'Sala Dos',
    description: 'Secundaria',
    address: 'Calle B',
    city: 'Madrid',
    province: 'Madrid',
    contactEmail: 'b@test.com',
    contactPhone: '+34 600 000 002',
    licenseNumber: 'LIC-2',
    maxCapacity: 80,
    accessibilityInfo: 'PMR',
  );

  setUp(() {
    venuesRepository = _MockVenuesRepository();
    authRepository = _MockAuthRepository();
  });

  ManagerVenuesCubit buildCubit() {
    return ManagerVenuesCubit(
      venuesRepository: venuesRepository,
      authRepository: authRepository,
    );
  }

  test('initial state is empty and idle', () {
    final cubit = buildCubit();
    expect(cubit.state.venues, isEmpty);
    expect(cubit.state.isLoading, false);
    expect(cubit.state.errorMessage, isNull);
    cubit.close();
  });

  blocTest<ManagerVenuesCubit, ManagerVenuesState>(
    'loadVenues emits loaded venues for authenticated manager',
    build: () {
      when(() => authRepository.currentUser).thenReturn(user);
      when(
        () => venuesRepository.getOwnerVenuesPage(
          ownerId: 'manager-1',
          limit: 24,
        ),
      ).thenAnswer(
        (_) async =>
            VenuesPage(items: [venue1], hasMore: false, nextCursor: null),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.loadVenues(),
    expect: () => [
      isA<ManagerVenuesState>().having((s) => s.isLoading, 'loading', true),
      isA<ManagerVenuesState>()
          .having((s) => s.isLoading, 'idle', false)
          .having((s) => s.venues.length, 'count', 1),
    ],
  );

  blocTest<ManagerVenuesCubit, ManagerVenuesState>(
    'loadMore appends next page without duplicates',
    build: () {
      when(() => authRepository.currentUser).thenReturn(user);
      when(
        () => venuesRepository.getOwnerVenuesPage(
          ownerId: 'manager-1',
          limit: 24,
        ),
      ).thenAnswer(
        (_) async =>
            VenuesPage(items: [venue1], hasMore: true, nextCursor: 'v-1'),
      );
      when(
        () => venuesRepository.getOwnerVenuesPage(
          ownerId: 'manager-1',
          cursor: 'v-1',
          limit: 24,
        ),
      ).thenAnswer(
        (_) async =>
            VenuesPage(items: [venue2], hasMore: false, nextCursor: null),
      );
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.loadVenues();
      await cubit.loadMore();
    },
    expect: () => [
      isA<ManagerVenuesState>().having((s) => s.isLoading, 'loading', true),
      isA<ManagerVenuesState>()
          .having((s) => s.isLoading, 'idle', false)
          .having((s) => s.venues.length, 'count', 1)
          .having((s) => s.hasMore, 'hasMore', true),
      isA<ManagerVenuesState>().having(
        (s) => s.isLoadingMore,
        'loading more',
        true,
      ),
      isA<ManagerVenuesState>()
          .having((s) => s.isLoadingMore, 'loading more end', false)
          .having((s) => s.venues.length, 'count', 2)
          .having((s) => s.hasMore, 'hasMore end', false),
    ],
  );

  blocTest<ManagerVenuesCubit, ManagerVenuesState>(
    'deactivateVenue removes venue from current list',
    build: () {
      when(() => authRepository.currentUser).thenReturn(user);
      when(
        () => venuesRepository.getOwnerVenuesPage(
          ownerId: 'manager-1',
          limit: 24,
        ),
      ).thenAnswer(
        (_) async =>
            VenuesPage(items: [venue1], hasMore: false, nextCursor: null),
      );
      when(
        () => venuesRepository.deactivateVenue('v-1'),
      ).thenAnswer((_) async {});
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.loadVenues();
      await cubit.deactivateVenue(venue1);
    },
    expect: () => [
      isA<ManagerVenuesState>().having((s) => s.isLoading, 'loading', true),
      isA<ManagerVenuesState>()
          .having((s) => s.venues.length, 'count', 1)
          .having((s) => s.isLoading, 'idle', false),
      isA<ManagerVenuesState>().having((s) => s.venues, 'removed', isEmpty),
    ],
  );
}
