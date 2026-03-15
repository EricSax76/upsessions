import 'package:equatable/equatable.dart';

import '../models/booking_entity.dart';
import 'studios_status.dart';

class MusicianBookingsState extends Equatable {
  static const Object _unset = Object();

  const MusicianBookingsState({
    this.status = StudiosStatus.initial,
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

  MusicianBookingsState copyWith({
    StudiosStatus? status,
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
    return MusicianBookingsState(
      status: status ?? this.status,
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
