import 'package:flutter/material.dart';

class MonthNavigationBar extends StatelessWidget {
  const MonthNavigationBar({
    super.key,
    required this.visibleMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime visibleMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final loc = MaterialLocalizations.of(context);
    return Row(
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
    );
  }
}

class MonthActionRow extends StatelessWidget {
  const MonthActionRow({
    super.key,
    required this.onGoToToday,
  });

  final VoidCallback onGoToToday;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onGoToToday,
        child: const Text('Hoy'),
      ),
    );
  }
}
