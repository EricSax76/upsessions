part of 'booking_cubit.dart';

enum BookingFormStatus { initial, loading, success, failure }

final class BookingState extends Equatable {
  const BookingState({
    this.status = BookingFormStatus.initial,
    this.selectedDate,
    this.selectedTime,
    this.durationHours = 2,
    this.totalPrice = 0,
    this.errorMessage,
  });

  final BookingFormStatus status;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final int durationHours;
  final double totalPrice;
  final String? errorMessage;

  BookingState copyWith({
    BookingFormStatus? status,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    int? durationHours,
    double? totalPrice,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      durationHours: durationHours ?? this.durationHours,
      totalPrice: totalPrice ?? this.totalPrice,
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
    errorMessage,
  ];
}
