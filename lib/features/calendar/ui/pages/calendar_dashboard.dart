import 'package:flutter/material.dart';

import '../../../events/models/event_entity.dart';
import '../../cubits/calendar_state.dart';
import '../widgets/calendar_hero_section.dart';
import '../widgets/month_calendar_card.dart';
import '../widgets/month_event_list.dart';
import '../widgets/selected_day_events_card.dart';

class CalendarDashboard extends StatelessWidget {
  const CalendarDashboard({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDay,
    required this.onGoToToday,
    required this.onViewEvent,
  });

  final CalendarState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;
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
          CalendarHeroSection(
            totalEvents: state.totalEvents,
            monthEvents: state.monthEvents.length,
          ),
          const SizedBox(height: 24),
          MonthCalendarCard(
            visibleMonth: state.visibleMonth,
            selectedDay: state.selectedDay,
            eventsByDay: state.eventsByDay,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            onSelectDay: onSelectDay,
            onGoToToday: onGoToToday,
          ),
          const SizedBox(height: 24),
          SelectedDayEventsCard(
            selectedDay: state.selectedDay,
            events: state.selectedDayEvents,
            onViewEvent: onViewEvent,
          ),
          const SizedBox(height: 24),
          MonthEventList(
            month: state.visibleMonth,
            events: state.monthEvents,
            onViewEvent: onViewEvent,
          ),
        ],
      ),
    );

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Stack(
            children: [
              content,
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: AnimatedOpacity(
                  opacity: state.loading ? 1 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: state.loading
                      ? const LinearProgressIndicator(minHeight: 3)
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
