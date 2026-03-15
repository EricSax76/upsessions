import 'package:flutter/material.dart';

import '../../models/room_entity.dart';

class RoomFormDraft {
  RoomFormDraft({RoomEntity? initialRoom}) {
    if (initialRoom != null) {
      fillFromRoom(initialRoom);
    } else {
      minBookingHoursController.text = '1';
    }
  }

  final nameController = TextEditingController();
  final capacityController = TextEditingController();
  final sizeController = TextEditingController();
  final priceController = TextEditingController();
  final equipmentController = TextEditingController();
  final minBookingHoursController = TextEditingController();
  final maxDecibelsController = TextEditingController();
  final ageRestrictionController = TextEditingController();
  final cancellationPolicyController = TextEditingController();

  bool isAccessible = false;
  bool isActive = true;

  void fillFromRoom(RoomEntity room) {
    nameController.text = room.name;
    capacityController.text = room.capacity.toString();
    sizeController.text = room.size;
    priceController.text = room.pricePerHour.toString();
    equipmentController.text = room.equipment.join(', ');
    minBookingHoursController.text = room.minBookingHours.toString();
    maxDecibelsController.text = room.maxDecibels == null
        ? ''
        : room.maxDecibels.toString();
    ageRestrictionController.text = room.ageRestriction == null
        ? ''
        : room.ageRestriction.toString();
    cancellationPolicyController.text = room.cancellationPolicy ?? '';
    isAccessible = room.isAccessible;
    isActive = room.isActive;
  }

  RoomEntity toRoomEntity({
    required String studioId,
    required String roomId,
    required List<String> photos,
    RoomEntity? fallback,
  }) {
    final parsedCapacity = int.tryParse(capacityController.text.trim());
    final parsedPrice = double.tryParse(priceController.text.trim());
    final parsedMinHours = int.tryParse(minBookingHoursController.text.trim());
    final parsedMaxDecibels = double.tryParse(
      maxDecibelsController.text.trim(),
    );
    final parsedAge = int.tryParse(ageRestrictionController.text.trim());

    final equipment = equipmentController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final cancellationPolicy = cancellationPolicyController.text.trim();

    return RoomEntity(
      id: roomId,
      studioId: studioId,
      name: nameController.text.trim(),
      capacity: parsedCapacity ?? fallback?.capacity ?? 0,
      size: sizeController.text.trim(),
      pricePerHour: parsedPrice ?? fallback?.pricePerHour ?? 0,
      equipment: equipment,
      amenities: fallback?.amenities ?? const [],
      photos: photos,
      minBookingHours: parsedMinHours ?? fallback?.minBookingHours ?? 1,
      maxDecibels: maxDecibelsController.text.trim().isEmpty
          ? null
          : parsedMaxDecibels,
      ageRestriction: ageRestrictionController.text.trim().isEmpty
          ? null
          : parsedAge,
      cancellationPolicy: cancellationPolicy.isEmpty
          ? null
          : cancellationPolicy,
      isAccessible: isAccessible,
      isActive: isActive,
    );
  }

  void dispose() {
    nameController.dispose();
    capacityController.dispose();
    sizeController.dispose();
    priceController.dispose();
    equipmentController.dispose();
    minBookingHoursController.dispose();
    maxDecibelsController.dispose();
    ageRestrictionController.dispose();
    cancellationPolicyController.dispose();
  }
}
