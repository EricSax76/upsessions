import 'package:flutter/material.dart';

import '../../../../modules/events/models/event_entity.dart';
import 'calendar_day_cell.dart';
import 'month_calendar_navigation.dart';

class MonthCalendarCard extends StatelessWidget {
  const MonthCalendarCard({
    super.key,
    required this.visibleMonth,
    required this.selectedDay,
    required this.eventsByDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDay,
    required this.onGoToToday,
  });

  final DateTime visibleMonth;
  final DateTime selectedDay;
  final Map<DateTime, List<EventEntity>> eventsByDay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onGoToToday;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MonthNavigationBar(
              visibleMonth: visibleMonth,
              onPreviousMonth: onPreviousMonth,
              onNextMonth: onNextMonth,
            ),
            MonthActionRow(onGoToToday: onGoToToday),
            const SizedBox(height: 8),
            const WeekdayHeader(),
            const SizedBox(height: 12),
            CalendarGrid(
              month: visibleMonth,
              selectedDay: selectedDay,
              eventsByDay: eventsByDay,
              onSelectDay: onSelectDay,
            ),
          ],
        ),
      ),
    );
  }
}

class WeekdayHeader extends StatelessWidget {
  const WeekdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final label in labels)
          Expanded(
            child: Center(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    super.key,
    required this.month,
    required this.selectedDay,
    required this.eventsByDay,
    required this.onSelectDay,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, List<EventEntity>> eventsByDay;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = firstDay.weekday; // Monday = 1
    final leadingEmpty = (firstWeekday + 6) % 7;
    final totalCells = leadingEmpty + daysInMonth;
    final trailingEmpty = (totalCells % 7) == 0 ? 0 : 7 - (totalCells % 7);
    final theme = Theme.of(context);

    final cells = <DateTime?>[
      ...List<DateTime?>.filled(leadingEmpty, null),
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(month.year, month.month, day),
      ...List<DateTime?>.filled(trailingEmpty, null),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cells.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemBuilder: (context, index) {
        final date = cells[index];
        if (date == null) {
          return const SizedBox.shrink();
        }
        final key = DateUtils.dateOnly(date);
        final hasEvents = eventsByDay.containsKey(key);
        final eventsCount = eventsByDay[key]?.length ?? 0;
        final isSelected = DateUtils.isSameDay(key, selectedDay);
        final isToday = DateUtils.isSameDay(
          key,
          DateUtils.dateOnly(DateTime.now()),
        );
        return CalendarDayCell(
          date: date,
          isSelected: isSelected,
          isToday: isToday,
          hasEvents: hasEvents,
          eventsCount: eventsCount,
          onTap: () => onSelectDay(key),
        );
      },
    );
  }
}
