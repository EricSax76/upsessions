import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/venues/cubits/public_venues_cubit.dart';
import 'package:upsessions/modules/venues/cubits/public_venues_state.dart';
import 'package:upsessions/modules/venues/models/venue_entity.dart';
import 'package:upsessions/modules/venues/repositories/venues_repository.dart';

class _MockVenuesRepository extends Mock implements VenuesRepository {}

void main() {
  late _MockVenuesRepository venuesRepository;

  final venue1 = VenueEntity(
    id: 'pv-1',
    ownerId: 'manager-1',
    name: 'Sala Norte',
    description: 'Sala pública',
    address: 'Calle Norte',
    city: 'Madrid',
    province: 'Madrid',
    contactEmail: 'north@test.com',
    contactPhone: '+34 600 000 010',
    licenseNumber: 'PV-1',
    maxCapacity: 140,
    accessibilityInfo: 'PMR',
  );

  final venue2 = VenueEntity(
    id: 'pv-2',
    ownerId: 'manager-2',
    name: 'Sala Sur',
    description: 'Otra sala pública',
    address: 'Calle Sur',
    city: 'Madrid',
    province: 'Madrid',
    contactEmail: 'south@test.com',
    contactPhone: '+34 600 000 011',
    licenseNumber: 'PV-2',
    maxCapacity: 90,
    accessibilityInfo: 'PMR',
  );

  setUp(() {
    venuesRepository = _MockVenuesRepository();
  });

  PublicVenuesCubit buildCubit() {
    return PublicVenuesCubit(venuesRepository: venuesRepository);
  }

  test('initial state is empty and idle', () {
    final cubit = buildCubit();
    expect(cubit.state.venues, isEmpty);
    expect(cubit.state.isLoading, false);
    expect(cubit.state.errorMessage, isNull);
    cubit.close();
  });

  blocTest<PublicVenuesCubit, PublicVenuesState>(
    'loadVenues emits loaded venues',
    build: () {
      when(
        () => venuesRepository.getPublicVenuesPage(
          city: null,
          province: null,
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
      isA<PublicVenuesState>().having((s) => s.isLoading, 'loading', true),
      isA<PublicVenuesState>()
          .having((s) => s.isLoading, 'idle', false)
          .having((s) => s.venues.length, 'count', 1),
    ],
  );

  blocTest<PublicVenuesCubit, PublicVenuesState>(
    'loadMore appends page after cursor',
    build: () {
      when(
        () => venuesRepository.getPublicVenuesPage(
          city: null,
          province: null,
          limit: 24,
        ),
      ).thenAnswer(
        (_) async =>
            VenuesPage(items: [venue1], hasMore: true, nextCursor: 'pv-1'),
      );
      when(
        () => venuesRepository.getPublicVenuesPage(
          cursor: 'pv-1',
          city: null,
          province: null,
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
      isA<PublicVenuesState>().having((s) => s.isLoading, 'loading', true),
      isA<PublicVenuesState>()
          .having((s) => s.venues.length, 'count', 1)
          .having((s) => s.hasMore, 'hasMore', true),
      isA<PublicVenuesState>().having(
        (s) => s.isLoadingMore,
        'loading more',
        true,
      ),
      isA<PublicVenuesState>()
          .having((s) => s.isLoadingMore, 'loading more end', false)
          .having((s) => s.venues.length, 'count', 2),
    ],
  );

  blocTest<PublicVenuesCubit, PublicVenuesState>(
    'applyFilters triggers filtered reload',
    build: () {
      when(
        () => venuesRepository.getPublicVenuesPage(
          city: 'Madrid',
          province: 'Madrid',
          limit: 24,
        ),
      ).thenAnswer(
        (_) async =>
            VenuesPage(items: [venue1], hasMore: false, nextCursor: null),
      );
      return buildCubit();
    },
    act: (cubit) => cubit.applyFilters(city: 'Madrid', province: 'Madrid'),
    expect: () => [
      isA<PublicVenuesState>()
          .having((s) => s.isLoading, 'loading', true)
          .having((s) => s.city, 'city', 'Madrid')
          .having((s) => s.province, 'province', 'Madrid'),
      isA<PublicVenuesState>()
          .having((s) => s.isLoading, 'idle', false)
          .having((s) => s.venues.length, 'count', 1),
    ],
  );
}
