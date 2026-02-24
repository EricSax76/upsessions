import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../modules/rehearsals/repositories/rehearsals_repository.dart';
import '../../cubits/calendar_cubit.dart';
import '../../cubits/calendar_state.dart';
import 'calendar_dashboard.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CalendarCubit(repository: context.read<RehearsalsRepository>()),
      child: BlocBuilder<CalendarCubit, CalendarState>(
        builder: (context, state) {
          final cubit = context.read<CalendarCubit>();
          return CalendarDashboard(
            state: state,
            onRefresh: cubit.refresh,
            onPreviousMonth: cubit.previousMonth,
            onNextMonth: cubit.nextMonth,
            onSelectDay: cubit.selectDay,
            onGoToToday: cubit.goToToday,
            onViewRehearsal: (rehearsal) {
              context.push(
                AppRoutes.rehearsalDetail(
                  groupId: rehearsal.groupId,
                  rehearsalId: rehearsal.id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
