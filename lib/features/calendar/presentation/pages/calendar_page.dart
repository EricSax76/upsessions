import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../../events/data/events_repository.dart';
import '../../../events/domain/event_entity.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final EventsRepository _repository = locate();
  bool _loading = true;
  List<EventEntity> _events = const [];
  Map<DateTime, List<EventEntity>> _eventsByDay = {};
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _visibleMonth = DateTime(today.year, today.month);
    _selectedDay = today;
    _load();
  }

  Future<void> _load() async {
    final events = await _repository.fetchUpcoming(limit: 60);
    if (!mounted) {
      return;
    }
    final grouped = <DateTime, List<EventEntity>>{};
    for (final event in events) {
      final dayKey = DateUtils.dateOnly(event.start);
      grouped.putIfAbsent(dayKey, () => []).add(event);
    }
    setState(() {
      _events = events;
      _eventsByDay = grouped;
      _loading = false;
      if (!_eventsByDay.containsKey(_selectedDay)) {
        if (events.isNotEmpty) {
          final firstEventDay = DateUtils.dateOnly(events.first.start);
          _selectedDay = firstEventDay;
          _visibleMonth = DateTime(firstEventDay.year, firstEventDay.month);
        } else {
          final today = DateUtils.dateOnly(DateTime.now());
          _selectedDay = today;
          _visibleMonth = DateTime(today.year, today.month);
        }
      }
    });
  }

  void _changeMonth(int offset) {
    final newMonth = DateTime(_visibleMonth.year, _visibleMonth.month + offset);
    setState(() {
      _visibleMonth = DateTime(newMonth.year, newMonth.month);
      _selectedDay = DateTime(newMonth.year, newMonth.month, 1);
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = day;
      _visibleMonth = DateTime(day.year, day.month);
    });
  }

  void _goToToday() {
    final today = DateUtils.dateOnly(DateTime.now());
    setState(() {
      _visibleMonth = DateTime(today.year, today.month);
      _selectedDay = today;
    });
  }

  void _viewEvent(EventEntity event) {
    if (!mounted) return;
    context.push(AppRoutes.eventDetail, extra: event);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayEvents =
        _eventsByDay[_selectedDay] ?? const <EventEntity>[];
    final monthEvents = _events
        .where(
          (event) =>
              event.start.year == _visibleMonth.year &&
              event.start.month == _visibleMonth.month,
        )
        .toList();

    return UserShellPage(
      child: _CalendarDashboard(
        loading: _loading,
        visibleMonth: _visibleMonth,
        selectedDay: _selectedDay,
        eventsByDay: _eventsByDay,
        monthEvents: monthEvents,
        selectedDayEvents: selectedDayEvents,
        onPreviousMonth: () => _changeMonth(-1),
        onNextMonth: () => _changeMonth(1),
        onSelectDay: _selectDay,
        onRefresh: _load,
        onGoToToday: _goToToday,
        onViewEvent: _viewEvent,
      ),
    );
  }
}

class _CalendarDashboard extends StatelessWidget {
  const _CalendarDashboard({
    required this.loading,
    required this.visibleMonth,
    required this.selectedDay,
    required this.eventsByDay,
    required this.monthEvents,
    required this.selectedDayEvents,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDay,
    required this.onRefresh,
    required this.onGoToToday,
    required this.onViewEvent,
  });

  final bool loading;
  final DateTime visibleMonth;
  final DateTime selectedDay;
  final Map<DateTime, List<EventEntity>> eventsByDay;
  final List<EventEntity> monthEvents;
  final List<EventEntity> selectedDayEvents;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;
  final Future<void> Function() onRefresh;
  final VoidCallback onGoToToday;
  final ValueChanged<EventEntity> onViewEvent;

  @override
  Widget build(BuildContext context) {
    final content = RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _CalendarIntro(
            totalEvents: eventsByDay.values.fold<int>(
              0,
              (sum, items) => sum + items.length,
            ),
            monthEvents: monthEvents.length,
          ),
          const SizedBox(height: 24),
          _MonthCalendarCard(
            visibleMonth: visibleMonth,
            selectedDay: selectedDay,
            eventsByDay: eventsByDay,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            onSelectDay: onSelectDay,
            onGoToToday: onGoToToday,
          ),
          const SizedBox(height: 24),
          _SelectedDayEvents(
            selectedDay: selectedDay,
            events: selectedDayEvents,
            onViewEvent: onViewEvent,
          ),
          const SizedBox(height: 24),
          _MonthEventList(
            month: visibleMonth,
            events: monthEvents,
            onViewEvent: onViewEvent,
          ),
        ],
      ),
    );

    return SafeArea(
      child: Stack(
        children: [
          content,
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AnimatedOpacity(
              opacity: loading ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: loading
                  ? const LinearProgressIndicator(minHeight: 3)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarIntro extends StatelessWidget {
  const _CalendarIntro({required this.totalEvents, required this.monthEvents});

  final int totalEvents;
  final int monthEvents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calendario',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Consulta las fechas registradas y mantén a tu equipo sincronizado con los showcases planificados.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _SummaryChip(
              label: 'Próximos registrados',
              value: '$totalEvents eventos',
              icon: Icons.event_available,
            ),
            _SummaryChip(
              label: 'En este mes',
              value: monthEvents.toString(),
              icon: Icons.calendar_month,
            ),
          ],
        ),
      ],
    );
  }
}

class _MonthCalendarCard extends StatelessWidget {
  const _MonthCalendarCard({
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
            _WeekdayHeader(),
            const SizedBox(height: 12),
            _CalendarGrid(
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

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

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

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
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
                      child: _EventMarkers(
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

class _EventMarkers extends StatelessWidget {
  const _EventMarkers({required this.count, required this.activeColor});

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

class _SelectedDayEvents extends StatelessWidget {
  const _SelectedDayEvents({
    required this.selectedDay,
    required this.events,
    required this.onViewEvent,
  });

  final DateTime selectedDay;
  final List<EventEntity> events;
  final ValueChanged<EventEntity> onViewEvent;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final label = loc.formatFullDate(selectedDay);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eventos para $label',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              Text(
                'No hay eventos registrados en esta fecha.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Column(
                children: [
                  for (final event in events)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: _EventTile(event: event, onViewEvent: onViewEvent),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthEventList extends StatelessWidget {
  const _MonthEventList({
    required this.month,
    required this.events,
    required this.onViewEvent,
  });

  final DateTime month;
  final List<EventEntity> events;
  final ValueChanged<EventEntity> onViewEvent;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final label = loc.formatMonthYear(month);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agenda de $label',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          Text(
            'No hay eventos en este mes, pero puedes registrar uno desde la sección de eventos.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          Column(
            children: [
              for (final event in events)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EventTile(event: event, onViewEvent: onViewEvent),
                ),
            ],
          ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onViewEvent});

  final EventEntity event;
  final ValueChanged<EventEntity> onViewEvent;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final startTime = loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.start));
    final endTime = loc.formatTimeOfDay(TimeOfDay.fromDateTime(event.end));
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      tileColor: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        event.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        '${loc.formatMediumDate(event.start)} · $startTime - $endTime · ${event.venue}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new),
        tooltip: 'Ver detalles',
        onPressed: () => onViewEvent(event),
      ),
      onTap: () => onViewEvent(event),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label),
            ],
          ),
        ],
      ),
    );
  }
}
