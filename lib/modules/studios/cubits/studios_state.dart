import 'package:equatable/equatable.dart';
import '../models/studio_entity.dart';
import '../models/room_entity.dart';
import '../models/booking_entity.dart';

enum StudiosStatus { initial, loading, success, failure }

class StudiosState extends Equatable {
  static const Object _unset = Object();

  const StudiosState({
    this.status = StudiosStatus.initial,
    this.studios = const [],
    this.hasMoreStudios = true,
    this.isLoadingStudiosMore = false,
    this.studiosCursor,
    this.myStudio,
    this.selectedStudio,
    this.selectedRoom,
    this.myRooms = const [],
    this.bookings = const [],
    this.myBookings = const [],
    this.hasMoreMyBookings = false,
    this.isLoadingMyBookingsMore = false,
    this.myBookingsCursor,
    this.upcomingMyBookings = const [],
    this.pastMyBookings = const [],
    this.studioBookings = const [],
    this.hasMoreStudioBookings = false,
    this.isLoadingStudioBookingsMore = false,
    this.studioBookingsCursor,
    this.errorMessage,
  });

  final StudiosStatus status;
  final List<StudioEntity> studios;
  final bool hasMoreStudios;
  final bool isLoadingStudiosMore;
  final String? studiosCursor;
  final StudioEntity? myStudio;
  final StudioEntity? selectedStudio;
  final RoomEntity? selectedRoom;
  final List<RoomEntity> myRooms;
  final List<BookingEntity> bookings;
  final List<BookingEntity> myBookings;
  final bool hasMoreMyBookings;
  final bool isLoadingMyBookingsMore;
  final String? myBookingsCursor;
  final List<BookingEntity> upcomingMyBookings;
  final List<BookingEntity> pastMyBookings;
  final List<BookingEntity> studioBookings;
  final bool hasMoreStudioBookings;
  final bool isLoadingStudioBookingsMore;
  final String? studioBookingsCursor;
  final String? errorMessage;

  StudiosState copyWith({
    StudiosStatus? status,
    List<StudioEntity>? studios,
    bool? hasMoreStudios,
    bool? isLoadingStudiosMore,
    Object? studiosCursor = _unset,
    Object? myStudio = _unset,
    Object? selectedStudio = _unset,
    Object? selectedRoom = _unset,
    List<RoomEntity>? myRooms,
    List<BookingEntity>? bookings,
    List<BookingEntity>? myBookings,
    bool? hasMoreMyBookings,
    bool? isLoadingMyBookingsMore,
    Object? myBookingsCursor = _unset,
    List<BookingEntity>? upcomingMyBookings,
    List<BookingEntity>? pastMyBookings,
    List<BookingEntity>? studioBookings,
    bool? hasMoreStudioBookings,
    bool? isLoadingStudioBookingsMore,
    Object? studioBookingsCursor = _unset,
    Object? errorMessage = _unset,
  }) {
    return StudiosState(
      status: status ?? this.status,
      studios: studios ?? this.studios,
      hasMoreStudios: hasMoreStudios ?? this.hasMoreStudios,
      isLoadingStudiosMore: isLoadingStudiosMore ?? this.isLoadingStudiosMore,
      studiosCursor: identical(studiosCursor, _unset)
          ? this.studiosCursor
          : studiosCursor as String?,
      myStudio: identical(myStudio, _unset)
          ? this.myStudio
          : myStudio as StudioEntity?,
      selectedStudio: identical(selectedStudio, _unset)
          ? this.selectedStudio
          : selectedStudio as StudioEntity?,
      selectedRoom: identical(selectedRoom, _unset)
          ? this.selectedRoom
          : selectedRoom as RoomEntity?,
      myRooms: myRooms ?? this.myRooms,
      bookings: bookings ?? this.bookings,
      myBookings: myBookings ?? this.myBookings,
      hasMoreMyBookings: hasMoreMyBookings ?? this.hasMoreMyBookings,
      isLoadingMyBookingsMore:
          isLoadingMyBookingsMore ?? this.isLoadingMyBookingsMore,
      myBookingsCursor: identical(myBookingsCursor, _unset)
          ? this.myBookingsCursor
          : myBookingsCursor as String?,
      upcomingMyBookings: upcomingMyBookings ?? this.upcomingMyBookings,
      pastMyBookings: pastMyBookings ?? this.pastMyBookings,
      studioBookings: studioBookings ?? this.studioBookings,
      hasMoreStudioBookings:
          hasMoreStudioBookings ?? this.hasMoreStudioBookings,
      isLoadingStudioBookingsMore:
          isLoadingStudioBookingsMore ?? this.isLoadingStudioBookingsMore,
      studioBookingsCursor: identical(studioBookingsCursor, _unset)
          ? this.studioBookingsCursor
          : studioBookingsCursor as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    studios,
    hasMoreStudios,
    isLoadingStudiosMore,
    studiosCursor,
    myStudio,
    selectedStudio,
    selectedRoom,
    myRooms,
    bookings,
    myBookings,
    hasMoreMyBookings,
    isLoadingMyBookingsMore,
    myBookingsCursor,
    upcomingMyBookings,
    pastMyBookings,
    studioBookings,
    hasMoreStudioBookings,
    isLoadingStudioBookingsMore,
    studioBookingsCursor,
    errorMessage,
  ];
}
