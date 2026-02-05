import 'package:equatable/equatable.dart';
import '../models/studio_entity.dart';
import '../models/room_entity.dart';
import '../models/booking_entity.dart';

enum StudiosStatus { initial, loading, success, failure }

class StudiosState extends Equatable {
  const StudiosState({
    this.status = StudiosStatus.initial,
    this.studios = const [],
    this.myStudio,
    this.selectedStudio,
    this.selectedRoom,
    this.myRooms = const [],
    this.bookings = const [],
    this.myBookings = const [],
    this.studioBookings = const [],
    this.errorMessage,
  });

  final StudiosStatus status;
  final List<StudioEntity> studios;
  final StudioEntity? myStudio;
  final StudioEntity? selectedStudio;
  final RoomEntity? selectedRoom;
  final List<RoomEntity> myRooms;
  final List<BookingEntity> bookings;
  final List<BookingEntity> myBookings;
  final List<BookingEntity> studioBookings;
  final String? errorMessage;

  StudiosState copyWith({
    StudiosStatus? status,
    List<StudioEntity>? studios,
    StudioEntity? myStudio,
    StudioEntity? selectedStudio,
    RoomEntity? selectedRoom,
    List<RoomEntity>? myRooms,
    List<BookingEntity>? bookings,
    List<BookingEntity>? myBookings,
    List<BookingEntity>? studioBookings,
    String? errorMessage,
  }) {
    return StudiosState(
      status: status ?? this.status,
      studios: studios ?? this.studios,
      myStudio: myStudio ?? this.myStudio,
      selectedStudio: selectedStudio ?? this.selectedStudio,
      selectedRoom: selectedRoom ?? this.selectedRoom,
      myRooms: myRooms ?? this.myRooms,
      bookings: bookings ?? this.bookings,
      myBookings: myBookings ?? this.myBookings,
      studioBookings: studioBookings ?? this.studioBookings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        studios,
        myStudio,
        selectedStudio,
        selectedRoom,
        myRooms,
        bookings,
        myBookings,
        studioBookings,
        errorMessage,
      ];
}
