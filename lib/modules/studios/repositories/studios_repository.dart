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

class MockStudiosRepository implements StudiosRepository {
  final List<StudioEntity> _studios = [];
  final List<RoomEntity> _rooms = [];
  final List<BookingEntity> _bookings = [];

  @override
  Future<void> createStudio(StudioEntity studio) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _studios.add(studio);
  }

  @override
  Future<void> updateStudio(StudioEntity studio) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _studios.indexWhere((s) => s.id == studio.id);
    if (index != -1) {
      _studios[index] = studio;
    }
  }

  @override
  Future<StudioEntity?> getStudioByOwner(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _studios.firstWhere((s) => s.ownerId == userId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<StudioEntity?> getStudioById(String studioId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _studios.firstWhere((s) => s.id == studioId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<StudiosPage> getStudiosPage({String? cursor, int limit = 20}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final sorted = List<StudioEntity>.from(_studios)
      ..sort((a, b) => a.id.compareTo(b.id));
    var startIndex = 0;
    if ((cursor ?? '').isNotEmpty) {
      final index = sorted.indexWhere((studio) => studio.id == cursor);
      if (index >= 0) {
        startIndex = index + 1;
      }
    }
    final remaining = sorted.length - startIndex;
    final takeCount = remaining > limit ? limit : remaining;
    final pageItems = takeCount <= 0
        ? const <StudioEntity>[]
        : sorted.sublist(startIndex, startIndex + takeCount);
    final hasMore = startIndex + takeCount < sorted.length;
    final nextCursor = hasMore && pageItems.isNotEmpty
        ? pageItems.last.id
        : null;
    return StudiosPage(
      items: pageItems,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  @override
  Future<List<StudioEntity>> getAllStudios() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_studios);
  }

  @override
  Future<void> createRoom(RoomEntity room) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _rooms.add(room);
  }

  @override
  Future<void> updateRoom(RoomEntity room) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      _rooms[index] = room;
    }
  }

  @override
  Future<void> deleteRoom({
    required String studioId,
    required String roomId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _rooms.removeWhere((r) => r.id == roomId && r.studioId == studioId);
  }

  @override
  Future<RoomEntity?> getRoomById({
    required String studioId,
    required String roomId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _rooms.firstWhere((r) => r.id == roomId && r.studioId == studioId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<RoomEntity>> getRoomsByStudio(String studioId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _rooms.where((r) => r.studioId == studioId).toList();
  }

  @override
  Future<void> createBooking(BookingEntity booking) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _bookings.add(booking);
  }

  @override
  Future<BookingEntity?> getBookingById(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _bookings.firstWhere((b) => b.id == bookingId);
    } catch (_) {
      return null;
    }
  }

  static int _startIndexFromCursor(List<BookingEntity> items, String? cursor) {
    final normalized = (cursor ?? '').trim();
    if (normalized.isEmpty) return 0;
    final index = items.indexWhere((booking) => booking.id == normalized);
    if (index < 0) return 0;
    return index + 1;
  }

  static List<BookingEntity> _sortedBookings(Iterable<BookingEntity> items) {
    final sorted = List<BookingEntity>.from(items);
    sorted.sort((a, b) {
      final byStart = b.startTime.compareTo(a.startTime);
      if (byStart != 0) return byStart;
      return b.id.compareTo(a.id);
    });
    return sorted;
  }

  BookingsPage _bookingsPageFrom({
    required Iterable<BookingEntity> source,
    String? cursor,
    int limit = 20,
  }) {
    final safeLimit = limit <= 0 ? 20 : limit;
    final sorted = _sortedBookings(source);
    final startIndex = _startIndexFromCursor(sorted, cursor);
    if (startIndex >= sorted.length) {
      return const BookingsPage(items: <BookingEntity>[], hasMore: false);
    }

    final endExclusive = (startIndex + safeLimit).clamp(0, sorted.length);
    final pageItems = sorted.sublist(startIndex, endExclusive);
    final hasMore = endExclusive < sorted.length;
    final nextCursor = hasMore && pageItems.isNotEmpty
        ? pageItems.last.id
        : null;
    return BookingsPage(
      items: pageItems,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  Future<List<BookingEntity>> _collectBookingsPages(
    Future<BookingsPage> Function(String? cursor) loadPage,
  ) async {
    final bookings = <BookingEntity>[];
    String? cursor;
    while (true) {
      final page = await loadPage(cursor);
      bookings.addAll(page.items);
      if (!page.hasMore || page.nextCursor == null) {
        break;
      }
      cursor = page.nextCursor;
    }
    return bookings;
  }

  @override
  Future<BookingsPage> getBookingsByRoomPage({
    required String roomId,
    String? cursor,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookingsPageFrom(
      source: _bookings.where((b) => b.roomId == roomId),
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<BookingsPage> getBookingsByUserPage({
    required String userId,
    String? cursor,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookingsPageFrom(
      source: _bookings.where((b) => b.ownerId == userId),
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<BookingsPage> getBookingsByStudioPage({
    required String studioId,
    String? cursor,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookingsPageFrom(
      source: _bookings.where((b) => b.studioId == studioId),
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<List<BookingEntity>> getBookingsByRoom(String roomId) async {
    return _collectBookingsPages(
      (cursor) => getBookingsByRoomPage(roomId: roomId, cursor: cursor),
    );
  }

  @override
  Future<List<BookingEntity>> getBookingsByUser(String userId) async {
    return _collectBookingsPages(
      (cursor) => getBookingsByUserPage(userId: userId, cursor: cursor),
    );
  }

  @override
  Future<List<BookingEntity>> getBookingsByStudio(String studioId) async {
    return _collectBookingsPages(
      (cursor) => getBookingsByStudioPage(studioId: studioId, cursor: cursor),
    );
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
    double? refundAmount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.cancelled,
        cancellationReason: reason,
        refundAmount: refundAmount,
        paymentStatus: refundAmount != null && refundAmount > 0
            ? BookingPaymentStatus.refunded
            : null,
      );
    }
  }

  @override
  Future<void> updateBookingPayment({
    required String bookingId,
    required BookingPaymentStatus paymentStatus,
    BookingPaymentMethod? paymentMethod,
    String? invoiceId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        paymentStatus: paymentStatus,
        paymentMethod: paymentMethod,
        invoiceId: invoiceId,
      );
    }
  }
}
