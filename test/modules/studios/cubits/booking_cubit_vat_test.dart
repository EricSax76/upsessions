import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/studios/cubits/booking_cubit.dart';
import 'package:upsessions/modules/studios/models/booking_entity.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';
import 'package:upsessions/modules/studios/ui/consumer/rehearsal_booking_context.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockStudiosRepository extends Mock implements StudiosRepository {}

class MockRehearsalsRepository extends Mock implements RehearsalsRepository {}

class MockUserEntity extends Mock implements UserEntity {}

void main() {
  group('BookingCubit VAT and booking payload', () {
    late MockAuthRepository authRepository;
    late MockStudiosRepository studiosRepository;
    late MockRehearsalsRepository rehearsalsRepository;
    late MockUserEntity user;

    const roomId = 'room-1';
    const roomName = 'Room 1';
    const studioId = 'studio-1';
    const studioName = 'Studio 1';
    const pricePerHour = 10.0;

    setUpAll(() {
      registerFallbackValue(
        BookingEntity(
          id: 'fallback',
          roomId: 'room',
          roomName: 'room',
          studioId: 'studio',
          studioName: 'studio',
          ownerId: 'owner',
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          status: BookingStatus.confirmed,
          totalPrice: 0,
          createdAt: DateTime.now(),
        ),
      );
    });

    setUp(() {
      authRepository = MockAuthRepository();
      studiosRepository = MockStudiosRepository();
      rehearsalsRepository = MockRehearsalsRepository();
      user = MockUserEntity();

      when(() => user.id).thenReturn('user-1');
      when(() => authRepository.currentUser).thenReturn(user);
      when(
        () => studiosRepository.createBooking(any()),
      ).thenAnswer((_) async {});
      when(
        () => rehearsalsRepository.getGroupMemberIds(any()),
      ).thenAnswer((_) async => const []);
      when(
        () => rehearsalsRepository.updateRehearsalBooking(
          groupId: any(named: 'groupId'),
          rehearsalId: any(named: 'rehearsalId'),
          bookingId: any(named: 'bookingId'),
        ),
      ).thenAnswer((_) async {});
    });

    BookingCubit buildCubit({RehearsalBookingContext? rehearsalContext}) {
      return BookingCubit(
        roomPricePerHour: pricePerHour,
        roomId: roomId,
        roomName: roomName,
        studioId: studioId,
        studioName: studioName,
        rehearsalContext: rehearsalContext,
        authRepository: authRepository,
        studiosRepository: studiosRepository,
        rehearsalsRepository: rehearsalsRepository,
      );
    }

    test('vatAmount is calculated as 21% for 1h booking', () async {
      final cubit = buildCubit();
      cubit.durationChanged(1);
      await cubit.confirmBooking();

      final booking =
          verify(
                () => studiosRepository.createBooking(captureAny()),
              ).captured.single
              as BookingEntity;
      expect(booking.totalPrice, 10.0);
      expect(booking.vatAmount, closeTo(2.1, 1e-9));
      await cubit.close();
    });

    test('vatAmount is calculated as 21% for 3h booking', () async {
      final cubit = buildCubit();
      cubit.durationChanged(3);
      await cubit.confirmBooking();

      final booking =
          verify(
                () => studiosRepository.createBooking(captureAny()),
              ).captured.single
              as BookingEntity;
      expect(booking.totalPrice, 30.0);
      expect(booking.vatAmount, closeTo(6.3, 1e-9));
      await cubit.close();
    });

    test('vatAmount is calculated as 21% for 8h booking', () async {
      final cubit = buildCubit();
      cubit.durationChanged(8);
      await cubit.confirmBooking();

      final booking =
          verify(
                () => studiosRepository.createBooking(captureAny()),
              ).captured.single
              as BookingEntity;
      expect(booking.totalPrice, 80.0);
      expect(booking.vatAmount, closeTo(16.8, 1e-9));
      await cubit.close();
    });

    test('paymentMethod is included in final BookingEntity', () async {
      final cubit = buildCubit();
      cubit.paymentMethodChanged(BookingPaymentMethod.transfer);
      await cubit.confirmBooking();

      final booking =
          verify(
                () => studiosRepository.createBooking(captureAny()),
              ).captured.single
              as BookingEntity;
      expect(booking.paymentMethod, BookingPaymentMethod.transfer);
      await cubit.close();
    });

    test('attendees is empty when rehearsalContext is null', () async {
      final cubit = buildCubit();
      await cubit.confirmBooking();

      final booking =
          verify(
                () => studiosRepository.createBooking(captureAny()),
              ).captured.single
              as BookingEntity;
      expect(booking.attendees, isEmpty);
      await cubit.close();
    });

    test('attendees is populated when rehearsalContext is provided', () async {
      const attendees = ['uid-1', 'uid-2'];
      when(
        () => rehearsalsRepository.getGroupMemberIds('group-1'),
      ).thenAnswer((_) async => attendees);

      final cubit = buildCubit(
        rehearsalContext: RehearsalBookingContext(
          groupId: 'group-1',
          rehearsalId: 'rehearsal-1',
          suggestedDate: DateTime(2026, 1, 1, 12),
          suggestedEndDate: DateTime(2026, 1, 1, 15),
        ),
      );
      await cubit.confirmBooking();

      final booking =
          verify(
                () => studiosRepository.createBooking(captureAny()),
              ).captured.single
              as BookingEntity;
      expect(booking.attendees, attendees);
      await cubit.close();
    });
  });
}
