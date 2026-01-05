import 'package:flutter/material.dart';

import '../../../../modules/events/models/event_entity.dart';

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
    final loc = MaterialLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onPreviousMonth,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Mes anterior',
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      loc.formatMonthYear(visibleMonth),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Mes siguiente',
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onGoToToday,
                child: const Text('Hoy'),
              ),
            ),
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
        final isSelected = DateUtils.isSameDay(key, selectedDay);
        final isToday = DateUtils.isSameDay(
          key,
          DateUtils.dateOnly(DateTime.now()),
        );
        final decoration = BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : null,
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                )
              : null,
        );
        final textStyle = theme.textTheme.titleMedium?.copyWith(
          color: isSelected ? Colors.white : null,
          fontWeight: FontWeight.w600,
        );
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelectDay(key),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: decoration,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text('${date.day}', style: textStyle),
                  if (hasEvents)
                    Positioned(
                      bottom: 6,
                      left: 0,
                      right: 0,
                      child: EventMarkers(
                        count: eventsByDay[key]!.length,
                        activeColor: isSelected
                            ? Colors.white
                            : theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class EventMarkers extends StatelessWidget {
  const EventMarkers({
    super.key,
    required this.count,
    required this.activeColor,
  });

  final int count;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final dots = count.clamp(1, 3);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < dots; i++) ...[
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: activeColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}
