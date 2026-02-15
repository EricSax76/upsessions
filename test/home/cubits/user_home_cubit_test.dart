import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/home/cubits/user_home_cubit.dart';
import 'package:upsessions/home/cubits/user_home_state.dart';
import 'package:upsessions/home/repositories/user_home_repository.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/modules/announcements/models/announcement_entity.dart';
import 'package:upsessions/home/models/instrument_category_model.dart';

class MockUserHomeRepository extends Mock implements UserHomeRepository {}

void main() {
  group('UserHomeCubit', () {
    late MockUserHomeRepository repository;

    setUp(() {
      repository = MockUserHomeRepository();
    });

    final mockMusician = MusicianEntity(
      id: '1',
      ownerId: 'owner1',
      name: 'John Doe',
      instrument: 'Guitar',
      city: 'Valencia',
      styles: const ['Rock'],
      experienceYears: 5,
    );

    final mockAnnouncement = AnnouncementEntity(
      id: '1',
      title: 'Band looking for drummer',
      body: 'Rock band',
      city: 'Valencia',
      author: 'User One',
      authorId: 'user1',
      province: 'Valencia',
      instrument: 'Drums',
      styles: const ['Rock'],
      publishedAt: DateTime.now(),
    );

    final mockCategory = InstrumentCategoryModel(
      category: 'Strings',
      instruments: ['Guitar', 'Violin'],
    );

    test('initial state is correct', () {
      expect(
        UserHomeCubit(repository: repository).state,
        const UserHomeState(),
      );
    });

    blocTest<UserHomeCubit, UserHomeState>(
      'loadHome emits loading and ready with data on success',
      setUp: () {
        when(
          () => repository.fetchRecommendedMusicians(),
        ).thenAnswer((_) async => [mockMusician]);
        when(
          () => repository.fetchNewMusicians(),
        ).thenAnswer((_) async => [mockMusician]);
        when(
          () => repository.fetchRecentAnnouncements(),
        ).thenAnswer((_) async => [mockAnnouncement]);
        when(
          () => repository.fetchInstrumentCategories(),
        ).thenAnswer((_) async => [mockCategory]);
        when(
          () => repository.fetchUpcomingEvents(),
        ).thenAnswer((_) async => []);
        when(
          () => repository.fetchUpcomingRehearsals(),
        ).thenAnswer((_) async => []);
        when(
          () => repository.fetchProvinces(),
        ).thenAnswer((_) async => ['Valencia']);
        when(
          () => repository.fetchCitiesForProvince(any()),
        ).thenAnswer((_) async => []);
      },
      build: () => UserHomeCubit(repository: repository),
      act: (cubit) => cubit.loadHome(),
      expect: () => [
        isA<UserHomeState>().having(
          (s) => s.status,
          'status',
          UserHomeStatus.loading,
        ),
        isA<UserHomeState>()
            .having((s) => s.status, 'status', UserHomeStatus.ready)
            .having((s) => s.recommended, 'recommended', [mockMusician])
            .having((s) => s.announcements, 'announcements', [mockAnnouncement])
            .having((s) => s.provinces, 'provinces', ['Valencia']),
      ],
    );

    blocTest<UserHomeCubit, UserHomeState>(
      'selectInstrument updates instrument state',
      build: () => UserHomeCubit(repository: repository),
      act: (cubit) => cubit.selectInstrument('Guitar'),
      expect: () => [
        isA<UserHomeState>().having(
          (s) => s.instrument,
          'instrument',
          'Guitar',
        ),
      ],
    );

    blocTest<UserHomeCubit, UserHomeState>(
      'selectProvince updates province and loads cities',
      setUp: () {
        when(
          () => repository.fetchCitiesForProvince('Valencia'),
        ).thenAnswer((_) async => ['Valencia', 'Alicante']);
      },
      build: () => UserHomeCubit(repository: repository),
      act: (cubit) => cubit.selectProvince('Valencia'),
      expect: () => [
        isA<UserHomeState>().having((s) => s.province, 'province', 'Valencia'),
        isA<UserHomeState>()
            .having((s) => s.cities, 'cities', ['Valencia', 'Alicante'])
            .having((s) => s.city, 'city', 'Valencia'),
      ],
    );
  });
}
