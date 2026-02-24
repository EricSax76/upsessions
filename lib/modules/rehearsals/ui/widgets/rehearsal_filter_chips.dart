import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../models/rehearsal_filter.dart';

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

    return SegmentedButton<RehearsalFilter>(
      segments: [
        ButtonSegment<RehearsalFilter>(
          value: RehearsalFilter.upcoming,
          label: Text(loc.rehearsalsFilterUpcoming),
        ),
        ButtonSegment<RehearsalFilter>(
          value: RehearsalFilter.past,
          label: Text(loc.rehearsalsFilterPast),
        ),
        ButtonSegment<RehearsalFilter>(
          value: RehearsalFilter.all,
          label: Text(loc.rehearsalsFilterAll),
        ),
      ],
      selected: {currentFilter},
      showSelectedIcon: false,
      onSelectionChanged: (Set<RehearsalFilter> newSelection) {
        onChanged(newSelection.first);
      },
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
