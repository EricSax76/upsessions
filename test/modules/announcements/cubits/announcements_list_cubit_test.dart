import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/announcements/cubits/announcements_list_cubit.dart';

import 'package:upsessions/modules/announcements/models/announcement_entity.dart';
import 'package:upsessions/modules/announcements/repositories/announcements_repository.dart';
import 'package:upsessions/modules/announcements/ui/widgets/announcement_list/announcement_filter_panel.dart';

class MockAnnouncementsRepository extends Mock
    implements AnnouncementsRepository {}

void main() {
  group('AnnouncementsListCubit', () {
    late MockAnnouncementsRepository repository;

    setUp(() {
      repository = MockAnnouncementsRepository();
    });

    final mockAnnouncements = List.generate(
      3,
      (i) => AnnouncementEntity(
        id: '$i',
        title: 'Title $i',
        body: 'Body $i',
        city: 'City',
        author: 'Author',
        authorId: 'auth-$i',
        province: 'Province',
        instrument: 'Instrument',
        styles: const [],
        publishedAt: DateTime.now(),
      ),
    );

    test('initial state is correct', () {
      final cubit = AnnouncementsListCubit(
        repository: repository,
        autoLoad: false,
      );
      expect(cubit.state, const AnnouncementsListState());
      cubit.close();
    });

    blocTest<AnnouncementsListCubit, AnnouncementsListState>(
      'load(refresh: true) emits success with items',
      setUp: () {
        when(
          () => repository.fetchPage(
            filter: AnnouncementFeedFilter.all,
            limit: 24,
            cursor: null,
          ),
        ).thenAnswer(
          (_) async => AnnouncementPage(
            items: mockAnnouncements,
            hasMore: true,
            nextCursor: 'next',
          ),
        );
      },
      build: () => AnnouncementsListCubit(
        repository: repository,
        autoLoad: false,
      ),
      act: (cubit) => cubit.load(refresh: true),
      expect: () => [
        const AnnouncementsListState(
          status: AnnouncementsListStatus.loading,
          items: [],
          hasMore: true,
        ),
        AnnouncementsListState(
          status: AnnouncementsListStatus.success,
          items: mockAnnouncements,
          hasMore: true,
          nextCursor: 'next',
        ),
      ],
    );

    blocTest<AnnouncementsListCubit, AnnouncementsListState>(
      'loadMore appends items',
      setUp: () {
        // Initial load
        when(
          () => repository.fetchPage(
            filter: AnnouncementFeedFilter.all,
            limit: 24,
            cursor: null,
          ),
        ).thenAnswer(
          (_) async => AnnouncementPage(
            items: mockAnnouncements,
            hasMore: true,
            nextCursor: 'cursor1',
          ),
        );

        // Load more
        when(
          () => repository.fetchPage(
            filter: AnnouncementFeedFilter.all,
            limit: 24,
            cursor: 'cursor1',
          ),
        ).thenAnswer(
          (_) async => AnnouncementPage(
            items: [mockAnnouncements[0]],
            hasMore: false,
            nextCursor: null,
          ),
        );
      },
      build: () => AnnouncementsListCubit(
        repository: repository,
        autoLoad: false,
      ),
      act: (cubit) async {
        await cubit.load(refresh: true);
        await cubit.loadMore();
      },
      expect: () => [
        const AnnouncementsListState(
          status: AnnouncementsListStatus.loading,
          items: [],
          hasMore: true,
        ),
        AnnouncementsListState(
          status: AnnouncementsListStatus.success,
          items: mockAnnouncements,
          hasMore: true,
          nextCursor: 'cursor1',
        ),
        AnnouncementsListState(
          status: AnnouncementsListStatus.success,
          items: mockAnnouncements,
          hasMore: true,
          nextCursor: 'cursor1',
          isLoadingMore: true,
        ),
        isA<AnnouncementsListState>()
            .having((s) => s.status, 'status', AnnouncementsListStatus.success)
            .having((s) => s.items.length, 'items count', 4)
            .having((s) => s.hasMore, 'hasMore', false)
            .having((s) => s.isLoadingMore, 'loadingMore', false),
      ],
    );

    blocTest<AnnouncementsListCubit, AnnouncementsListState>(
      'setFilter reloads with new filter',
      setUp: () {
        when(
          () => repository.fetchPage(
            filter: AnnouncementFeedFilter.nearby,
            limit: 24,
            cursor: null,
          ),
        ).thenAnswer(
          (_) async =>
              AnnouncementPage(items: mockAnnouncements, hasMore: false),
        );
      },
      build: () => AnnouncementsListCubit(
        repository: repository,
        autoLoad: false,
      ),
      act: (cubit) => cubit.setFilter(AnnouncementUiFilter.nearby),
      expect: () => [
        const AnnouncementsListState(filter: AnnouncementUiFilter.nearby),
        // load (refresh)
        isA<AnnouncementsListState>().having(
          (s) => s.status,
          'status',
          AnnouncementsListStatus.loading,
        ),
        // load success
        isA<AnnouncementsListState>()
            .having((s) => s.status, 'status', AnnouncementsListStatus.success)
            .having((s) => s.filter, 'filter', AnnouncementUiFilter.nearby)
            .having((s) => s.items.length, 'items', 3),
      ],
    );
  });
}
