import '../models/studio_entity.dart';
import '../models/room_entity.dart';
import '../models/booking_entity.dart';

abstract class StudiosRepository {
  Future<void> createStudio(StudioEntity studio);
  Future<void> updateStudio(StudioEntity studio);
  Future<StudioEntity?> getStudioByOwner(String userId);
  Future<StudioEntity?> getStudioById(String studioId);
  Future<List<StudioEntity>> getAllStudios();
  
  Future<void> createRoom(RoomEntity room);
  Future<void> updateRoom(RoomEntity room);
  Future<void> deleteRoom(String roomId);
  Future<List<RoomEntity>> getRoomsByStudio(String studioId);

  Future<void> createBooking(BookingEntity booking);
  Future<List<BookingEntity>> getBookingsByRoom(String roomId);
  Future<List<BookingEntity>> getBookingsByUser(String userId);
  Future<List<BookingEntity>> getBookingsByStudio(String studioId);
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
  Future<void> deleteRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _rooms.removeWhere((r) => r.id == roomId);
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
  Future<List<BookingEntity>> getBookingsByRoom(String roomId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookings.where((b) => b.roomId == roomId).toList();
  }

  @override
  Future<List<BookingEntity>> getBookingsByUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _bookings.where((b) => b.ownerId == userId).toList();
  }

  @override
  Future<List<BookingEntity>> getBookingsByStudio(String studioId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Since BookingEntity now has studioId, we can filter directly
    return _bookings.where((b) => b.studioId == studioId).toList();
  }
}
