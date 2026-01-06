import 'package:flutter/material.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.hasEvents,
    required this.eventsCount,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool hasEvents;
  final int eventsCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      onTap: onTap,
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
                    count: eventsCount,
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
