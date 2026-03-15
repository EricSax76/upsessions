import '../models/studio_entity.dart';
import '../models/room_entity.dart';
import '../models/booking_entity.dart';

class StudiosPage {
  const StudiosPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<StudioEntity> items;
  final bool hasMore;
  final String? nextCursor;
}

class BookingsPage {
  const BookingsPage({
    required this.items,
    required this.hasMore,
    this.nextCursor,
  });

  final List<BookingEntity> items;
  final bool hasMore;
  final String? nextCursor;
}

abstract class StudiosRepository {
  Future<void> createStudio(StudioEntity studio);
  Future<void> updateStudio(StudioEntity studio);
  Future<StudioEntity?> getStudioByOwner(String userId);
  Future<StudioEntity?> getStudioById(String studioId);
  Future<StudiosPage> getStudiosPage({String? cursor, int limit = 20});
  Future<List<StudioEntity>> getAllStudios();

  Future<void> createRoom(RoomEntity room);
  Future<void> updateRoom(RoomEntity room);
  Future<void> deleteRoom({required String studioId, required String roomId});
  Future<RoomEntity?> getRoomById({
    required String studioId,
    required String roomId,
  });
  Future<List<RoomEntity>> getRoomsByStudio(String studioId);

  Future<void> createBooking(BookingEntity booking);
  Future<BookingEntity?> getBookingById(String bookingId);
  Future<BookingsPage> getBookingsByRoomPage({
    required String roomId,
    String? cursor,
    int limit = 20,
  });
  Future<BookingsPage> getBookingsByUserPage({
    required String userId,
    String? cursor,
    int limit = 20,
  });
  Future<BookingsPage> getBookingsByStudioPage({
    required String studioId,
    String? cursor,
    int limit = 20,
  });
  Future<List<BookingEntity>> getBookingsByRoom(String roomId);
  Future<List<BookingEntity>> getBookingsByUser(String userId);
  Future<List<BookingEntity>> getBookingsByStudio(String studioId);

  /// Cancela una reserva con motivo (Directiva 2011/83/UE).
  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
    double? refundAmount,
  });

  /// Actualiza el estado de pago de una reserva (PSD2 / contabilidad).
  Future<void> updateBookingPayment({
    required String bookingId,
    required BookingPaymentStatus paymentStatus,
    BookingPaymentMethod? paymentMethod,
    String? invoiceId,
  });
}
