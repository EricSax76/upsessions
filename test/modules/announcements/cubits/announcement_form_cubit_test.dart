import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/announcements/cubits/announcement_form_cubit.dart';
import 'package:upsessions/modules/announcements/models/announcement_entity.dart';
import 'package:upsessions/modules/announcements/repositories/announcements_repository.dart';
import 'package:upsessions/modules/announcements/services/announcement_image_service.dart';

class MockAnnouncementsRepository extends Mock implements AnnouncementsRepository {}
class MockAnnouncementImageService extends Mock implements AnnouncementImageService {}
class MockXFile extends Mock implements XFile {}
class FakeXFile extends Fake implements XFile {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeXFile());
  });

  group('AnnouncementFormCubit', () {
    late MockAnnouncementsRepository repository;
    late MockAnnouncementImageService imageService;
    late AnnouncementEntity dummyEntity;

    setUp(() {
      repository = MockAnnouncementsRepository();
      imageService = MockAnnouncementImageService();
      
      dummyEntity = AnnouncementEntity(
        id: '',
        title: 'Test',
        body: 'Body',
        city: 'City',
        author: '',
        authorId: '',
        province: 'Province',
        instrument: 'Instr',
        styles: const [],
        publishedAt: DateTime.now(),
      );

      registerFallbackValue(dummyEntity);
    });

    blocTest<AnnouncementFormCubit, AnnouncementFormState>(
      'submit success without image',
      setUp: () {
        when(() => repository.create(any())).thenAnswer((_) async => dummyEntity);
      },
      build: () => AnnouncementFormCubit(
        repository: repository,
        imageService: imageService,
      ),
      act: (cubit) => cubit.submit(
        entity: dummyEntity,
        authorId: 'auth-1',
        authorName: 'Author',
      ),
      expect: () => [
        const AnnouncementFormState(status: AnnouncementFormStatus.submitting),
        const AnnouncementFormState(status: AnnouncementFormStatus.success),
      ],
      verify: (_) {
        verify(() => repository.create(any())).called(1);
        verifyNever(() => imageService.uploadImage(any()));
      },
    );

    blocTest<AnnouncementFormCubit, AnnouncementFormState>(
      'submit success with image',
      setUp: () {
        when(() => imageService.uploadImage(any())).thenAnswer((_) async => 'http://image.url');
        when(() => repository.create(any())).thenAnswer((_) async => dummyEntity);
      },
      build: () => AnnouncementFormCubit(
        repository: repository,
        imageService: imageService,
      ),
      act: (cubit) {
        final image = MockXFile();
        cubit.submit(
          entity: dummyEntity,
          authorId: 'auth-1',
          authorName: 'Author',
          pickedImage: image,
        );
      },
      expect: () => [
        const AnnouncementFormState(status: AnnouncementFormStatus.submitting),
        const AnnouncementFormState(status: AnnouncementFormStatus.success),
      ],
      verify: (_) {
        verify(() => imageService.uploadImage(any())).called(1);
        verify(() => repository.create(any(that: 
          isA<AnnouncementEntity>().having((e) => e.imageUrl, 'imageUrl', 'http://image.url')
        ))).called(1);
      },
    );

    blocTest<AnnouncementFormCubit, AnnouncementFormState>(
      'submit failure',
      setUp: () {
        when(() => repository.create(any())).thenAnswer(
          (_) => Future<AnnouncementEntity>.error(Exception('DB Error')),
        );
      },
      build: () => AnnouncementFormCubit(
        repository: repository,
        imageService: imageService,
      ),
      act: (cubit) => cubit.submit(
        entity: dummyEntity,
        authorId: 'auth-1',
        authorName: 'Author',
      ),
      expect: () => [
        const AnnouncementFormState(status: AnnouncementFormStatus.submitting),
        const AnnouncementFormState(status: AnnouncementFormStatus.failure, errorMessage: 'Exception: DB Error'),
      ],
    );
  });
}
