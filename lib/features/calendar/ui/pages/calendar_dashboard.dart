import 'package:flutter/material.dart';

import '../../../events/domain/event_entity.dart';
import '../../models/calendar_controller.dart';
import '../widgets/calendar_intro.dart';
import '../widgets/month_calendar_card.dart';
import '../widgets/month_event_list.dart';
import '../widgets/selected_day_events_card.dart';

class CalendarDashboard extends StatelessWidget {
  const CalendarDashboard({
    super.key,
    required this.controller,
    required this.onViewEvent,
  });

  final CalendarController controller;
  final ValueChanged<EventEntity> onViewEvent;

  @override
  Widget build(BuildContext context) {
    final content = RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          CalendarIntro(
            totalEvents: controller.totalEvents,
            monthEvents: controller.monthEvents.length,
          ),
          const SizedBox(height: 24),
          MonthCalendarCard(
            visibleMonth: controller.visibleMonth,
            selectedDay: controller.selectedDay,
            eventsByDay: controller.eventsByDay,
            onPreviousMonth: controller.previousMonth,
            onNextMonth: controller.nextMonth,
            onSelectDay: controller.selectDay,
            onGoToToday: controller.goToToday,
          ),
          const SizedBox(height: 24),
          SelectedDayEventsCard(
            selectedDay: controller.selectedDay,
            events: controller.selectedDayEvents,
            onViewEvent: onViewEvent,
          ),
          const SizedBox(height: 24),
          MonthEventList(
            month: controller.visibleMonth,
            events: controller.monthEvents,
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
              opacity: controller.loading ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              child: controller.loading
                  ? const LinearProgressIndicator(minHeight: 3)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
