import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../../events/models/event_entity.dart';
import '../../models/calendar_controller.dart';
import 'calendar_dashboard.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final CalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController(repository: locate());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _viewEvent(EventEntity event) {
    if (!mounted) return;
    context.push(AppRoutes.eventDetailPath(event.id), extra: event);
  }

  @override
  Widget build(BuildContext context) {
    return UserShellPage(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) =>
            CalendarDashboard(controller: _controller, onViewEvent: _viewEvent),
      ),
    );
  }
}
