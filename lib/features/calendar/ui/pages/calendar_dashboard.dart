import 'package:flutter/material.dart';

import '../../../../modules/rehearsals/models/rehearsal_entity.dart';
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
    required this.onViewRehearsal,
  });

  final CalendarState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onGoToToday;
  final ValueChanged<RehearsalEntity> onViewRehearsal;

  @override
  Widget build(BuildContext context) {
    final content = RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          CalendarHeroSection(
            totalRehearsals: state.totalUpcomingRehearsals,
            monthRehearsals: state.monthRehearsals.length,
          ),
          const SizedBox(height: 24),
          MonthCalendarCard(
            visibleMonth: state.visibleMonth,
            selectedDay: state.selectedDay,
            rehearsalsByDay: state.rehearsalsByDay,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            onSelectDay: onSelectDay,
            onGoToToday: onGoToToday,
          ),
          const SizedBox(height: 24),
          SelectedDayRehearsalsCard(
            selectedDay: state.selectedDay,
            rehearsals: state.selectedDayRehearsals,
            onViewRehearsal: onViewRehearsal,
          ),
          const SizedBox(height: 24),
          MonthRehearsalList(
            month: state.visibleMonth,
            rehearsals: state.monthRehearsals,
            onViewRehearsal: onViewRehearsal,
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
