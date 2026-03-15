import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/home/cubits/user_home_cubit.dart';
import 'package:upsessions/features/home/cubits/user_home_state.dart';
import 'package:upsessions/features/home/models/instrument_category_model.dart';
import 'package:upsessions/features/home/repositories/home_announcements_repository.dart';
import 'package:upsessions/features/home/repositories/home_events_repository.dart';
import 'package:upsessions/features/home/repositories/home_metadata_repository.dart';
import 'package:upsessions/features/home/repositories/home_musicians_repository.dart';
import 'package:upsessions/features/home/repositories/home_rehearsals_repository.dart';
import 'package:upsessions/modules/announcements/models/announcement_entity.dart';
import 'package:upsessions/modules/musicians/models/musician_compliance_info.dart';
import 'package:upsessions/modules/musicians/models/musician_entity.dart';
import 'package:upsessions/modules/musicians/models/musician_professional_info.dart';

class MockHomeMusiciansRepository extends Mock
    implements HomeMusiciansRepository {}

class MockHomeAnnouncementsRepository extends Mock
    implements HomeAnnouncementsRepository {}

class MockHomeMetadataRepository extends Mock
    implements HomeMetadataRepository {}

class MockHomeEventsRepository extends Mock implements HomeEventsRepository {}

class MockHomeRehearsalsRepository extends Mock
    implements HomeRehearsalsRepository {}

void main() {
  group('UserHomeCubit', () {
    late MockHomeMusiciansRepository musiciansRepository;
    late MockHomeAnnouncementsRepository announcementsRepository;
    late MockHomeMetadataRepository metadataRepository;
    late MockHomeEventsRepository eventsRepository;
    late MockHomeRehearsalsRepository rehearsalsRepository;

    setUp(() {
      musiciansRepository = MockHomeMusiciansRepository();
      announcementsRepository = MockHomeAnnouncementsRepository();
      metadataRepository = MockHomeMetadataRepository();
      eventsRepository = MockHomeEventsRepository();
      rehearsalsRepository = MockHomeRehearsalsRepository();
    });

    final mockMusician = MusicianEntity(
      id: '1',
      ownerId: 'owner1',
      name: 'John Doe',
      instrument: 'Guitar',
      city: 'Valencia',
      styles: const ['Rock'],
      experienceYears: 5,
      compliance: MusicianComplianceInfo(updatedAt: DateTime.now()),
      professional: const MusicianProfessionalInfo(),
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

    UserHomeCubit buildCubit() {
      return UserHomeCubit(
        musiciansRepository: musiciansRepository,
        announcementsRepository: announcementsRepository,
        metadataRepository: metadataRepository,
        eventsRepository: eventsRepository,
        rehearsalsRepository: rehearsalsRepository,
      );
    }

    test('initial state is correct', () {
      expect(buildCubit().state, const UserHomeState());
    });

    blocTest<UserHomeCubit, UserHomeState>(
      'loadHome emits loading and ready with data on success',
      setUp: () {
        when(
          () => musiciansRepository.fetchRecommendedMusicians(),
        ).thenAnswer((_) async => [mockMusician]);
        when(
          () => musiciansRepository.fetchNewMusicians(),
        ).thenAnswer((_) async => [mockMusician]);
        when(
          () => announcementsRepository.fetchRecentAnnouncements(),
        ).thenAnswer((_) async => [mockAnnouncement]);
        when(
          () => metadataRepository.fetchInstrumentCategories(),
        ).thenAnswer((_) async => [mockCategory]);
        when(
          () => eventsRepository.fetchUpcomingEvents(),
        ).thenAnswer((_) async => []);
        when(
          () => rehearsalsRepository.fetchUpcomingRehearsals(),
        ).thenAnswer((_) async => []);
        when(
          () => metadataRepository.fetchProvinces(),
        ).thenAnswer((_) async => ['Valencia']);
      },
      build: buildCubit,
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
      build: buildCubit,
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
          () => metadataRepository.fetchCitiesForProvince('Valencia'),
        ).thenAnswer((_) async => ['Valencia', 'Alicante']);
      },
      build: buildCubit,
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
