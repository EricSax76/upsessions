import 'package:bloc_test/bloc_test.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';
import 'package:upsessions/modules/auth/models/user_entity.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';
import 'package:upsessions/modules/studios/cubits/booking_cubit.dart';
import 'package:upsessions/modules/studios/models/booking_entity.dart';
import 'package:upsessions/modules/studios/repositories/studios_repository.dart';
import 'package:upsessions/modules/studios/ui/consumer/studios_list_page.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockStudiosRepository extends Mock implements StudiosRepository {}

class MockRehearsalsRepository extends Mock implements RehearsalsRepository {}

class MockUserEntity extends Mock implements UserEntity {}

void main() {
  group('BookingCubit', () {
    late MockAuthRepository authRepository;
    late MockStudiosRepository studiosRepository;
    late MockRehearsalsRepository rehearsalsRepository;
    late MockUserEntity user;

    const roomId = 'room-1';
    const roomName = 'Room 1';
    const studioId = 'studio-1';
    const studioName = 'Studio 1';
    const pricePerHour = 10.0;

    setUp(() {
      authRepository = MockAuthRepository();
      studiosRepository = MockStudiosRepository();
      rehearsalsRepository = MockRehearsalsRepository();
      user = MockUserEntity();

      when(() => user.id).thenReturn('user-1');
      when(() => authRepository.currentUser).thenReturn(user);
    });

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
          status: BookingStatus.confirmed, // Entity status
          totalPrice: 0,
        ),
      );
    });

    test('initial state is correct (default)', () {
      final cubit = BookingCubit(
        roomPricePerHour: pricePerHour,
        roomId: roomId,
        roomName: roomName,
        studioId: studioId,
        studioName: studioName,
        authRepository: authRepository,
        studiosRepository: studiosRepository,
        rehearsalsRepository: rehearsalsRepository,
      );

      expect(cubit.state.durationHours, 2);
      expect(cubit.state.totalPrice, 20.0);
      expect(cubit.state.status, BookingFormStatus.initial);
      cubit.close();
    });

    test('initial state with rehearsal context', () {
      final date = DateTime(2025, 1, 1, 10, 0);
      final endDate = date.add(const Duration(hours: 3));
      final context = RehearsalBookingContext(
        groupId: 'g1',
        rehearsalId: 'r1',
        suggestedDate: date,
        suggestedEndDate: endDate,
      );

      final cubit = BookingCubit(
        roomPricePerHour: pricePerHour,
        roomId: roomId,
        roomName: roomName,
        studioId: studioId,
        studioName: studioName,
        rehearsalContext: context,
        authRepository: authRepository,
        studiosRepository: studiosRepository,
        rehearsalsRepository: rehearsalsRepository,
      );

      expect(cubit.state.selectedDate, date);
      expect(cubit.state.selectedTime?.hour, 10);
      expect(cubit.state.durationHours, 3);
      expect(cubit.state.totalPrice, 30.0);
      cubit.close();
    });

    blocTest<BookingCubit, BookingState>(
      'durationChanged updates duration and price',
      build: () => BookingCubit(
        roomPricePerHour: pricePerHour,
        roomId: roomId,
        roomName: roomName,
        studioId: studioId,
        studioName: studioName,
        authRepository: authRepository,
        studiosRepository: studiosRepository,
        rehearsalsRepository: rehearsalsRepository,
      ),
      act: (cubit) => cubit.durationChanged(4),
      expect: () => [
        isA<BookingState>()
            .having((s) => s.durationHours, 'duration', 4)
            .having((s) => s.totalPrice, 'price', 40.0),
      ],
    );

    blocTest<BookingCubit, BookingState>(
      'confirmBooking success',
      setUp: () {
        when(
          () => studiosRepository.createBooking(any()),
        ).thenAnswer((_) async {});
      },
      build: () => BookingCubit(
        roomPricePerHour: pricePerHour,
        roomId: roomId,
        roomName: roomName,
        studioId: studioId,
        studioName: studioName,
        authRepository: authRepository,
        studiosRepository: studiosRepository,
        rehearsalsRepository: rehearsalsRepository,
      ),
      act: (cubit) => cubit.confirmBooking(),
      expect: () => [
        isA<BookingState>().having(
          (s) => s.status,
          'status',
          BookingFormStatus.loading,
        ),
        isA<BookingState>().having(
          (s) => s.status,
          'status',
          BookingFormStatus.success,
        ),
      ],
      verify: (_) {
        verify(() => studiosRepository.createBooking(any())).called(1);
      },
    );

    blocTest<BookingCubit, BookingState>(
      'confirmBooking fails when not logged in',
      setUp: () {
        when(() => authRepository.currentUser).thenReturn(null);
      },
      build: () => BookingCubit(
        roomPricePerHour: pricePerHour,
        roomId: roomId,
        roomName: roomName,
        studioId: studioId,
        studioName: studioName,
        authRepository: authRepository,
        studiosRepository: studiosRepository,
        rehearsalsRepository: rehearsalsRepository,
      ),
      act: (cubit) => cubit.confirmBooking(),
      expect: () => [
        isA<BookingState>()
            .having((s) => s.status, 'status', BookingFormStatus.failure)
            .having(
              (s) => s.errorMessage,
              'error',
              'Debes iniciar sesión para reservar.',
            ),
      ],
    );
  });
}
