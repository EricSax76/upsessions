import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../controllers/rehearsal_filter.dart';

/// Filter chips for selecting rehearsal time periods.
class RehearsalFilterChips extends StatelessWidget {
  const RehearsalFilterChips({
    super.key,
    required this.currentFilter,
    required this.onChanged,
  });

  final RehearsalFilter currentFilter;
  final ValueChanged<RehearsalFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text(loc.rehearsalsFilterUpcoming),
          selected: currentFilter == RehearsalFilter.upcoming,
          onSelected: (_) => onChanged(RehearsalFilter.upcoming),
        ),
        ChoiceChip(
          label: Text(loc.rehearsalsFilterPast),
          selected: currentFilter == RehearsalFilter.past,
          onSelected: (_) => onChanged(RehearsalFilter.past),
        ),
        ChoiceChip(
          label: Text(loc.rehearsalsFilterAll),
          selected: currentFilter == RehearsalFilter.all,
          onSelected: (_) => onChanged(RehearsalFilter.all),
        ),
      ],
    );
  }
}
