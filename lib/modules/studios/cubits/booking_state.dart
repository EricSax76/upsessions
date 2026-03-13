part of 'booking_cubit.dart';

enum BookingFormStatus { initial, loading, success, failure }

final class BookingState extends Equatable {
  const BookingState({
    this.status = BookingFormStatus.initial,
    this.selectedDate,
    this.selectedTime,
    this.durationHours = 2,
    this.totalPrice = 0,
    this.paymentMethod,
    this.attendees = const [],
    this.errorMessage,
  });

  final BookingFormStatus status;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final int durationHours;
  final double totalPrice;
  final BookingPaymentMethod? paymentMethod;
  final List<String> attendees;
  final String? errorMessage;

  BookingState copyWith({
    BookingFormStatus? status,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    int? durationHours,
    double? totalPrice,
    BookingPaymentMethod? paymentMethod,
    List<String>? attendees,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      durationHours: durationHours ?? this.durationHours,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      attendees: attendees ?? this.attendees,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedDate,
    selectedTime,
    durationHours,
    totalPrice,
    paymentMethod,
    attendees,
    errorMessage,
  ];
}
