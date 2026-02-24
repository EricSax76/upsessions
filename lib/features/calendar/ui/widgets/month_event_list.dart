import 'package:flutter/material.dart';

import '../../../../modules/rehearsals/models/rehearsal_entity.dart';
import '../../../../core/widgets/section_card.dart';
import 'event_tile.dart';

enum CalendarFeedFilter { past, today, upcoming }

class MonthRehearsalList extends StatefulWidget {
  const MonthRehearsalList({
    super.key,
    required this.month,
    required this.rehearsals,
    required this.onViewRehearsal,
  });

  final DateTime month;
  final List<RehearsalEntity> rehearsals;
  final ValueChanged<RehearsalEntity> onViewRehearsal;

  @override
  State<MonthRehearsalList> createState() => _MonthRehearsalListState();
}

class _MonthRehearsalListState extends State<MonthRehearsalList> {
  CalendarFeedFilter _currentFilter = CalendarFeedFilter.upcoming;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final label = loc.formatMonthYear(widget.month);
    final filteredRehearsals = _filterRehearsals(
      widget.rehearsals,
      _currentFilter,
    );

    return SectionCard(
      title: 'Agenda de ensayos de $label',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<CalendarFeedFilter>(
            segments: const [
              ButtonSegment<CalendarFeedFilter>(
                value: CalendarFeedFilter.past,
                label: Text('Pasados'),
              ),
              ButtonSegment<CalendarFeedFilter>(
                value: CalendarFeedFilter.today,
                label: Text('Hoy'),
              ),
              ButtonSegment<CalendarFeedFilter>(
                value: CalendarFeedFilter.upcoming,
                label: Text('Próximos'),
              ),
            ],
            selected: {_currentFilter},
            showSelectedIcon: false,
            onSelectionChanged: (selection) {
              setState(() {
                _currentFilter = selection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(height: 16),
          if (filteredRehearsals.isEmpty)
            Text(
              _emptyMessage(_currentFilter),
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Column(
              children: [
                for (final rehearsal in filteredRehearsals)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RehearsalTile(
                      rehearsal: rehearsal,
                      onViewRehearsal: widget.onViewRehearsal,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  List<RehearsalEntity> _filterRehearsals(
    List<RehearsalEntity> rehearsals,
    CalendarFeedFilter filter,
  ) {
    if (rehearsals.isEmpty) return const [];

    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    switch (filter) {
      case CalendarFeedFilter.past:
        return rehearsals
            .where((rehearsal) => rehearsal.startsAt.isBefore(now))
            .toList()
          ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
      case CalendarFeedFilter.today:
        return rehearsals
            .where(
              (rehearsal) => DateUtils.isSameDay(rehearsal.startsAt, today),
            )
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      case CalendarFeedFilter.upcoming:
        return rehearsals
            .where((rehearsal) => !rehearsal.startsAt.isBefore(now))
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    }
  }

  String _emptyMessage(CalendarFeedFilter filter) {
    switch (filter) {
      case CalendarFeedFilter.past:
        return 'No hay ensayos pasados en este periodo.';
      case CalendarFeedFilter.today:
        return 'No hay ensayos para hoy.';
      case CalendarFeedFilter.upcoming:
        return 'No hay ensayos próximos en este periodo.';
    }
  }
}
