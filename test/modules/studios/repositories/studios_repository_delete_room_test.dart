import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/studios/models/room_entity.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';

void main() {
  group('MockStudiosRepository.deleteRoom', () {
    test(
      'removes only the room that matches both studioId and roomId',
      () async {
        final repository = MockStudiosRepository();

        const roomId = 'room-shared';
        const studioA = 'studio-a';
        const studioB = 'studio-b';

        await repository.createRoom(
          const RoomEntity(
            id: roomId,
            studioId: studioA,
            name: 'Room A',
            capacity: 4,
            size: '20m2',
            equipment: [],
            amenities: [],
            pricePerHour: 20,
            photos: [],
          ),
        );
        await repository.createRoom(
          const RoomEntity(
            id: roomId,
            studioId: studioB,
            name: 'Room B',
            capacity: 6,
            size: '30m2',
            equipment: [],
            amenities: [],
            pricePerHour: 30,
            photos: [],
          ),
        );

        await repository.deleteRoom(studioId: studioA, roomId: roomId);

        final remainingStudioARooms = await repository.getRoomsByStudio(studioA);
        final remainingStudioBRooms = await repository.getRoomsByStudio(studioB);

        expect(remainingStudioARooms, isEmpty);
        expect(remainingStudioBRooms, hasLength(1));
        expect(remainingStudioBRooms.single.id, roomId);
        expect(remainingStudioBRooms.single.studioId, studioB);
      },
    );
  });
}
