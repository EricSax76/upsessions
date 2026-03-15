import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/studios/cubits/my_studio_cubit.dart';
import 'package:upsessions/modules/studios/cubits/room_form_cubit.dart';
import 'package:upsessions/modules/studios/models/room_entity.dart';

class _MockMyStudioCubit extends Mock implements MyStudioCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const RoomEntity(
        id: 'room-id',
        studioId: 'studio-id',
        name: 'name',
        capacity: 1,
        size: '1x1',
        equipment: [],
        amenities: [],
        pricePerHour: 1,
        photos: [],
      ),
    );
  });

  test(
    'submit uploads photos, builds entity and dispatches createRoom',
    () async {
      final myStudioCubit = _MockMyStudioCubit();
      when(() => myStudioCubit.createRoom(any())).thenAnswer((_) async {});

      final cubit = RoomFormCubit(
        studioCubit: myStudioCubit,
        idGenerator: () => 'room-1',
      );

      cubit.draft.nameController.text = 'Room A';
      cubit.draft.capacityController.text = '5';
      cubit.draft.sizeController.text = '5x5';
      cubit.draft.priceController.text = '22.5';
      cubit.draft.equipmentController.text = 'amp, mic';
      cubit.draft.minBookingHoursController.text = '2';
      cubit.draft.maxDecibelsController.text = '95';
      cubit.draft.ageRestrictionController.text = '18';
      cubit.draft.cancellationPolicyController.text = '24h';
      cubit.draft.isAccessible = true;
      cubit.draft.isActive = true;

      await cubit.submit(
        studioId: 'studio-1',
        uploadPhotos: (_) async => ['photo-1'],
      );

      final captured =
          verify(() => myStudioCubit.createRoom(captureAny())).captured.single
              as RoomEntity;

      expect(captured.id, 'room-1');
      expect(captured.studioId, 'studio-1');
      expect(captured.name, 'Room A');
      expect(captured.capacity, 5);
      expect(captured.size, '5x5');
      expect(captured.pricePerHour, 22.5);
      expect(captured.equipment, ['amp', 'mic']);
      expect(captured.photos, ['photo-1']);
      expect(captured.minBookingHours, 2);
      expect(captured.maxDecibels, 95);
      expect(captured.ageRestriction, 18);
      expect(captured.cancellationPolicy, '24h');
      expect(captured.isAccessible, isTrue);
      expect(captured.isActive, isTrue);
      expect(cubit.state.isSubmitting, isFalse);
      expect(cubit.state.errorMessage, isNull);

      await cubit.close();
    },
  );

  test('submit stores error when upload fails', () async {
    final myStudioCubit = _MockMyStudioCubit();
    when(() => myStudioCubit.createRoom(any())).thenAnswer((_) async {});

    final cubit = RoomFormCubit(studioCubit: myStudioCubit);

    await cubit.submit(
      studioId: 'studio-1',
      uploadPhotos: (_) async => throw Exception('upload failed'),
    );

    expect(cubit.state.isSubmitting, isFalse);
    expect(cubit.state.errorMessage, contains('upload failed'));
    verifyNever(() => myStudioCubit.createRoom(any()));

    await cubit.close();
  });
}
