import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/studios/models/room_entity.dart';
import 'package:upsessions/modules/studios/ui/forms/room_form_draft.dart';

void main() {
  test('fillFromRoom hydrates room draft fields', () {
    final room = _roomFixture();
    final draft = RoomFormDraft(initialRoom: room);

    expect(draft.nameController.text, room.name);
    expect(draft.capacityController.text, room.capacity.toString());
    expect(draft.sizeController.text, room.size);
    expect(draft.priceController.text, room.pricePerHour.toString());
    expect(draft.equipmentController.text, room.equipment.join(', '));
    expect(
      draft.minBookingHoursController.text,
      room.minBookingHours.toString(),
    );
    expect(draft.maxDecibelsController.text, room.maxDecibels.toString());
    expect(draft.ageRestrictionController.text, room.ageRestriction.toString());
    expect(draft.cancellationPolicyController.text, room.cancellationPolicy);
    expect(draft.isAccessible, isTrue);
    expect(draft.isActive, isFalse);

    draft.dispose();
  });

  test('toRoomEntity parses values and falls back when invalid', () {
    final fallback = _roomFixture();
    final draft = RoomFormDraft();
    draft.nameController.text = '  New Room  ';
    draft.capacityController.text = 'invalid';
    draft.sizeController.text = ' 3x3m ';
    draft.priceController.text = '20.5';
    draft.equipmentController.text = 'drums, amp,  , mic';
    draft.minBookingHoursController.text = '2';
    draft.maxDecibelsController.text = '';
    draft.ageRestrictionController.text = '';
    draft.cancellationPolicyController.text = ' 24h '; // trim
    draft.isAccessible = true;
    draft.isActive = true;

    final room = draft.toRoomEntity(
      studioId: 'studio-1',
      roomId: 'room-1',
      photos: const ['photo-a'],
      fallback: fallback,
    );

    expect(room.id, 'room-1');
    expect(room.studioId, 'studio-1');
    expect(room.name, 'New Room');
    expect(room.capacity, fallback.capacity);
    expect(room.size, '3x3m');
    expect(room.pricePerHour, 20.5);
    expect(room.equipment, ['drums', 'amp', 'mic']);
    expect(room.minBookingHours, 2);
    expect(room.maxDecibels, isNull);
    expect(room.ageRestriction, isNull);
    expect(room.cancellationPolicy, '24h');
    expect(room.photos, ['photo-a']);
    expect(room.isAccessible, isTrue);
    expect(room.isActive, isTrue);

    draft.dispose();
  });
}

RoomEntity _roomFixture() {
  return RoomEntity(
    id: 'room-0',
    studioId: 'studio-0',
    name: 'Room 0',
    capacity: 4,
    size: '4x4m',
    equipment: const ['amp', 'mic'],
    amenities: const ['wifi'],
    pricePerHour: 18,
    photos: const ['photo-0'],
    maxDecibels: 90,
    isAccessible: true,
    minBookingHours: 2,
    cancellationPolicy: '48h',
    isActive: false,
    ageRestriction: 18,
  );
}
