import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:upsessions/features/calendar/cubits/calendar_cubit.dart';
import 'package:upsessions/features/calendar/cubits/calendar_state.dart';
import 'package:upsessions/modules/rehearsals/models/rehearsal_entity.dart';
import 'package:upsessions/modules/rehearsals/repositories/rehearsals_repository.dart';

class MockRehearsalsRepository extends Mock implements RehearsalsRepository {}

void main() {
  late MockRehearsalsRepository repository;

  final today = DateUtils.dateOnly(DateTime.now());
  final tomorrow = today.add(const Duration(days: 1));

  final mockRehearsals = <RehearsalEntity>[
    RehearsalEntity(
      id: '1',
      groupId: 'group-1',
      startsAt: today,
      endsAt: today.add(const Duration(hours: 2)),
      location: 'Studio A',
      notes: 'Band rehearsal',
      createdBy: 'owner-1',
    ),
    RehearsalEntity(
      id: '2',
      groupId: 'group-1',
      startsAt: tomorrow,
      endsAt: tomorrow.add(const Duration(hours: 3)),
      location: 'Club B',
      notes: 'Live gig',
      createdBy: 'owner-1',
    ),
  ];

  setUp(() {
    repository = MockRehearsalsRepository();
  });

  group('CalendarCubit', () {
    blocTest<CalendarCubit, CalendarState>(
      'refresh loads rehearsals and groups by day',
      build: () {
        when(
          () => repository.getMyRehearsals(),
        ).thenAnswer((_) async => mockRehearsals);
        return CalendarCubit(repository: repository, autoRefresh: false);
      },
      act: (cubit) => cubit.refresh(),
      expect: () => [
        isA<CalendarState>().having((s) => s.loading, 'loading', true),
        isA<CalendarState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.rehearsals.length, 'rehearsals', 2)
            .having((s) => s.rehearsalsByDay.length, 'days', 2),
      ],
    );

    blocTest<CalendarCubit, CalendarState>(
      'selectDay updates selectedDay and visibleMonth',
      build: () {
        return CalendarCubit(repository: repository, autoRefresh: false);
      },
      act: (cubit) {
        final target = DateTime(2025, 6, 15);
        cubit.selectDay(target);
      },
      expect: () => [
        isA<CalendarState>()
            .having((s) => s.selectedDay, 'day', DateTime(2025, 6, 15))
            .having((s) => s.visibleMonth, 'month', DateTime(2025, 6)),
      ],
    );

    blocTest<CalendarCubit, CalendarState>(
      'nextMonth and previousMonth navigate months',
      build: () {
        return CalendarCubit(repository: repository, autoRefresh: false);
      },
      act: (cubit) {
        cubit.nextMonth();
        cubit.previousMonth();
      },
      expect: () {
        final nextMonth = DateTime(today.year, today.month + 1);
        final currentMonth = DateTime(today.year, today.month);
        return [
          isA<CalendarState>().having(
            (s) => s.visibleMonth,
            'next',
            DateTime(nextMonth.year, nextMonth.month),
          ),
          isA<CalendarState>().having(
            (s) => s.visibleMonth,
            'prev',
            DateTime(currentMonth.year, currentMonth.month),
          ),
        ];
      },
    );

    blocTest<CalendarCubit, CalendarState>(
      'goToToday resets to today',
      build: () {
        return CalendarCubit(repository: repository, autoRefresh: false);
      },
      act: (cubit) {
        cubit.selectDay(DateTime(2025, 3, 10));
        cubit.goToToday();
      },
      expect: () => [
        isA<CalendarState>().having(
          (s) => s.selectedDay,
          'day',
          DateTime(2025, 3, 10),
        ),
        isA<CalendarState>()
            .having((s) => s.selectedDay, 'today', today)
            .having(
              (s) => s.visibleMonth,
              'month',
              DateTime(today.year, today.month),
            ),
      ],
    );
  });
}
