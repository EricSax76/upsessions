import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/calendar/cubits/calendar_cubit.dart';
import 'package:upsessions/features/calendar/cubits/calendar_state.dart';
import 'package:upsessions/features/events/models/event_entity.dart';
import 'package:upsessions/features/events/repositories/events_repository.dart';

class MockEventsRepository extends Mock implements EventsRepository {}

void main() {
  late MockEventsRepository repository;

  final today = DateUtils.dateOnly(DateTime.now());
  final tomorrow = today.add(const Duration(days: 1));

  final mockEvents = <EventEntity>[
    EventEntity(
      id: '1',
      ownerId: 'owner-1',
      title: 'Rehearsal',
      city: 'Madrid',
      venue: 'Studio A',
      start: today,
      end: today.add(const Duration(hours: 2)),
      description: 'Band rehearsal',
      organizer: 'John',
      contactEmail: 'john@example.com',
      contactPhone: '+34600000000',
      lineup: const ['Guitar', 'Drums'],
      tags: const ['rehearsal'],
      ticketInfo: 'Free',
      capacity: 10,
      resources: const [],
    ),
    EventEntity(
      id: '2',
      ownerId: 'owner-1',
      title: 'Gig',
      city: 'Barcelona',
      venue: 'Club B',
      start: tomorrow,
      end: tomorrow.add(const Duration(hours: 3)),
      description: 'Live gig',
      organizer: 'Jane',
      contactEmail: 'jane@example.com',
      contactPhone: '+34600000001',
      lineup: const ['Guitar', 'Bass', 'Drums'],
      tags: const ['gig', 'live'],
      ticketInfo: '10€',
      capacity: 50,
      resources: const [],
    ),
  ];

  setUp(() {
    repository = MockEventsRepository();
  });

  group('CalendarCubit', () {
    blocTest<CalendarCubit, CalendarState>(
      'refresh loads events and groups by day',
      build: () {
        when(() => repository.fetchUpcoming(limit: 60))
            .thenAnswer((_) async => mockEvents);
        return CalendarCubit(
          repository: repository,
          autoRefresh: false,
        );
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        isA<CalendarState>().having((s) => s.loading, 'loading', true),
        isA<CalendarState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.events.length, 'events', 2)
            .having((s) => s.eventsByDay.length, 'days', 2),
      ],
    );

    blocTest<CalendarCubit, CalendarState>(
      'selectDay updates selectedDay and visibleMonth',
      build: () {
        return CalendarCubit(
          repository: repository,
          autoRefresh: false,
        );
      },
      act: (cubit) {
        final target = DateTime(2025, 6, 15);
        cubit.selectDay(target);
      },
      expect: () => [
        isA<CalendarState>()
            .having((s) => s.selectedDay, 'day', DateTime(2025, 6, 15))
            .having(
                (s) => s.visibleMonth, 'month', DateTime(2025, 6)),
      ],
    );

    blocTest<CalendarCubit, CalendarState>(
      'nextMonth and previousMonth navigate months',
      build: () {
        return CalendarCubit(
          repository: repository,
          autoRefresh: false,
        );
      },
      act: (cubit) {
        cubit.nextMonth();
        cubit.previousMonth();
      },
      expect: () {
        final nextMonth = DateTime(today.year, today.month + 1);
        final currentMonth = DateTime(today.year, today.month);
        return [
          isA<CalendarState>()
              .having((s) => s.visibleMonth, 'next',
                  DateTime(nextMonth.year, nextMonth.month)),
          isA<CalendarState>()
              .having((s) => s.visibleMonth, 'prev',
                  DateTime(currentMonth.year, currentMonth.month)),
        ];
      },
    );

    blocTest<CalendarCubit, CalendarState>(
      'goToToday resets to today',
      build: () {
        return CalendarCubit(
          repository: repository,
          autoRefresh: false,
        );
      },
      act: (cubit) {
        cubit.selectDay(DateTime(2025, 3, 10));
        cubit.goToToday();
      },
      expect: () => [
        isA<CalendarState>()
            .having((s) => s.selectedDay, 'day', DateTime(2025, 3, 10)),
        isA<CalendarState>()
            .having((s) => s.selectedDay, 'today', today)
            .having((s) => s.visibleMonth, 'month',
                DateTime(today.year, today.month)),
      ],
    );
  });
}
