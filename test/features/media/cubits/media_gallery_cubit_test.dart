import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/media/cubits/media_gallery_cubit.dart';
import 'package:upsessions/features/media/cubits/media_gallery_state.dart';
import 'package:upsessions/features/media/models/media_item.dart';
import 'package:upsessions/features/media/repositories/media_repository.dart';

class MockMediaRepository extends Mock implements MediaRepository {}

void main() {
  late MockMediaRepository repository;

  final mockItems = [
    const MediaItem(
      id: '1',
      title: 'Song A',
      type: MediaType.audio,
      duration: Duration(minutes: 3, seconds: 45),
      url: 'https://example.com/a.mp3',
    ),
    const MediaItem(
      id: '2',
      title: 'Video B',
      type: MediaType.video,
      duration: Duration(minutes: 5),
      url: 'https://example.com/b.mp4',
    ),
  ];

  setUp(() {
    repository = MockMediaRepository();
  });

  group('MediaGalleryCubit', () {
    test('initial state is correct', () {
      final cubit = MediaGalleryCubit(repository: repository);
      expect(cubit.state.status, MediaGalleryStatus.initial);
      expect(cubit.state.items, isEmpty);
      cubit.close();
    });

    blocTest<MediaGalleryCubit, MediaGalleryState>(
      'load emits loading then loaded with items',
      build: () {
        when(() => repository.fetchMedia())
            .thenAnswer((_) async => mockItems);
        return MediaGalleryCubit(repository: repository);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<MediaGalleryState>()
            .having((s) => s.status, 'loading', MediaGalleryStatus.loading),
        isA<MediaGalleryState>()
            .having((s) => s.status, 'loaded', MediaGalleryStatus.loaded)
            .having((s) => s.items.length, 'itemCount', 2),
      ],
    );

    blocTest<MediaGalleryCubit, MediaGalleryState>(
      'load emits error on failure',
      build: () {
        when(() => repository.fetchMedia())
            .thenThrow(Exception('Network error'));
        return MediaGalleryCubit(repository: repository);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<MediaGalleryState>()
            .having((s) => s.status, 'loading', MediaGalleryStatus.loading),
        isA<MediaGalleryState>()
            .having((s) => s.status, 'error', MediaGalleryStatus.error)
            .having((s) => s.errorMessage, 'msg', contains('Network error')),
      ],
    );
  });
}
