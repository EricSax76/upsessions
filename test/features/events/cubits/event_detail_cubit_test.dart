import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/events/cubits/event_detail_cubit.dart';
import 'package:upsessions/features/events/cubits/event_detail_state.dart';
import 'package:upsessions/features/events/models/event_entity.dart';
import 'package:upsessions/features/events/repositories/events_repository.dart';
import 'package:upsessions/features/events/services/image_upload_service.dart';

class MockEventsRepository extends Mock implements EventsRepository {}

class MockImageUploadService extends Mock implements ImageUploadService {}

void main() {
  setUpAll(() {
    registerFallbackValue(EventEntity(
      id: '',
      ownerId: '',
      title: '',
      city: '',
      venue: '',
      start: DateTime(2026),
      end: DateTime(2026),
      description: '',
      organizer: '',
      contactEmail: '',
      contactPhone: '',
      lineup: const [],
      tags: const [],
      ticketInfo: '',
      capacity: 0,
      resources: const [],
    ));
  });

  late MockEventsRepository repository;
  late MockImageUploadService imageUploadService;

  final mockEvent = EventEntity(
    id: 'event-1',
    ownerId: 'owner-1',
    title: 'Jazz Night',
    city: 'Valencia',
    venue: 'Blue Note',
    start: DateTime(2026, 3, 1, 19, 0),
    end: DateTime(2026, 3, 1, 22, 0),
    description: 'A great jazz night',
    organizer: 'Jazz Club',
    contactEmail: 'info@jazz.com',
    contactPhone: '123456789',
    lineup: const ['Coltrane', 'Miles'],
    tags: const ['jazz', 'live'],
    ticketInfo: '10€',
    capacity: 100,
    resources: const [],
  );

  setUp(() {
    repository = MockEventsRepository();
    imageUploadService = MockImageUploadService();
  });

  EventDetailCubit buildCubit() {
    return EventDetailCubit(
      event: mockEvent,
      repository: repository,
      imageUploadService: imageUploadService,
    );
  }

  group('EventDetailCubit', () {
    test('initial state has event and idle status', () {
      final cubit = buildCubit();
      expect(cubit.state.event, mockEvent);
      expect(cubit.state.status, EventDetailStatus.idle);
      expect(cubit.state.isUploadingBanner, false);
      expect(cubit.state.effect, isNull);
      cubit.close();
    });

    blocTest<EventDetailCubit, EventDetailState>(
      'uploadBanner emits uploading then bannerUpdated on success',
      build: () {
        when(() => imageUploadService.uploadEventBanner(any()))
            .thenAnswer((_) async => 'https://img.com/banner.jpg');
        when(() => repository.saveDraft(any()))
            .thenAnswer((_) async => mockEvent.copyWith(
                  bannerImageUrl: 'https://img.com/banner.jpg',
                ));
        return buildCubit();
      },
      act: (cubit) => cubit.uploadBanner(),
      expect: () => [
        isA<EventDetailState>()
            .having((s) => s.isUploadingBanner, 'uploading', true),
        isA<EventDetailState>()
            .having((s) => s.isUploadingBanner, 'idle', false)
            .having(
                (s) => s.effect, 'effect', EventDetailEffect.bannerUpdated)
            .having((s) => s.event.bannerImageUrl, 'bannerUrl',
                'https://img.com/banner.jpg'),
      ],
    );

    blocTest<EventDetailCubit, EventDetailState>(
      'uploadBanner emits bannerCancelled when user cancels',
      build: () {
        when(() => imageUploadService.uploadEventBanner(any()))
            .thenAnswer((_) async => null);
        return buildCubit();
      },
      act: (cubit) => cubit.uploadBanner(),
      expect: () => [
        isA<EventDetailState>()
            .having((s) => s.isUploadingBanner, 'uploading', true),
        isA<EventDetailState>()
            .having((s) => s.isUploadingBanner, 'idle', false)
            .having(
                (s) => s.effect, 'effect', EventDetailEffect.bannerCancelled),
      ],
    );

    blocTest<EventDetailCubit, EventDetailState>(
      'shareEvent emits shareComingSoon effect',
      build: buildCubit,
      act: (cubit) => cubit.shareEvent(),
      expect: () => [
        isA<EventDetailState>().having(
            (s) => s.effect, 'effect', EventDetailEffect.shareComingSoon),
      ],
    );

    test('clearEffect clears the effect', () {
      final cubit = buildCubit();
      cubit.shareEvent();
      expect(cubit.state.effect, EventDetailEffect.shareComingSoon);
      cubit.clearEffect();
      expect(cubit.state.effect, isNull);
      cubit.close();
    });
  });
}
