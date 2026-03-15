import 'package:flutter_test/flutter_test.dart';
import 'package:upsessions/modules/studios/models/booking_entity.dart';
import 'package:upsessions/modules/studios/models/room_entity.dart';
import '../../../support/studios/mock_studios_repository.dart';

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

        final remainingStudioARooms = await repository.getRoomsByStudio(
          studioA,
        );
        final remainingStudioBRooms = await repository.getRoomsByStudio(
          studioB,
        );

        expect(remainingStudioARooms, isEmpty);
        expect(remainingStudioBRooms, hasLength(1));
        expect(remainingStudioBRooms.single.id, roomId);
        expect(remainingStudioBRooms.single.studioId, studioB);
      },
    );
  });

  group('MockStudiosRepository booking mutations', () {
    Future<MockStudiosRepository> seedRepositoryWithBooking() async {
      final repository = MockStudiosRepository();
      await repository.createBooking(
        BookingEntity(
          id: 'booking-1',
          roomId: 'room-1',
          roomName: 'Room 1',
          studioId: 'studio-1',
          studioName: 'Studio 1',
          ownerId: 'user-1',
          startTime: DateTime(2026, 1, 1, 10),
          endTime: DateTime(2026, 1, 1, 12),
          status: BookingStatus.confirmed,
          totalPrice: 100,
          createdAt: DateTime(2026, 1, 1, 9),
        ),
      );
      return repository;
    }

    test('cancelBooking updates status and cancellationReason', () async {
      final repository = await seedRepositoryWithBooking();

      await repository.cancelBooking(
        bookingId: 'booking-1',
        reason: 'Cliente no puede asistir',
      );

      final updated = await repository.getBookingById('booking-1');
      expect(updated, isNotNull);
      expect(updated!.status, BookingStatus.cancelled);
      expect(updated.cancellationReason, 'Cliente no puede asistir');
    });

    test(
      'updateBookingPayment updates paymentStatus and paymentMethod',
      () async {
        final repository = await seedRepositoryWithBooking();

        await repository.updateBookingPayment(
          bookingId: 'booking-1',
          paymentStatus: BookingPaymentStatus.paid,
          paymentMethod: BookingPaymentMethod.card,
        );

        final updated = await repository.getBookingById('booking-1');
        expect(updated, isNotNull);
        expect(updated!.paymentStatus, BookingPaymentStatus.paid);
        expect(updated.paymentMethod, BookingPaymentMethod.card);
      },
    );
  });
}
