import 'package:flutter/material.dart';

import '../../../../core/widgets/gap.dart';
import '../../../../core/widgets/empty_state_card.dart';
import '../../../../home/ui/widgets/home_section_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../cubits/rehearsal_entity.dart';
import '../models/rehearsal_filter.dart';
import 'rehearsal_card.dart';
import 'rehearsal_filter_chips.dart';
import '../pages/group_rehearsals_page.dart';

/// Main content card displaying rehearsal list with filters.
class RehearsalListCard extends StatelessWidget {
  const RehearsalListCard({
    super.key,
    required this.rehearsals,
    required this.filtered,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.onRehearsalTap,
    required this.showCreateButton,
    this.onCreateRehearsal,
    this.isMediumScreen = false,
  });

  final List<RehearsalEntity> rehearsals;
  final List<RehearsalEntity> filtered;
  final RehearsalFilter currentFilter;
  final ValueChanged<RehearsalFilter> onFilterChanged;
  final void Function(RehearsalEntity) onRehearsalTap;
  final bool showCreateButton;
  final VoidCallback? onCreateRehearsal;
  final bool isMediumScreen;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return HomeSectionCard(
      title: loc.navRehearsals,
      subtitle: loc.rehearsalsPageSubtitle,
      action: isMediumScreen
          ? RehearsalFilterChips(
              currentFilter: currentFilter,
              onChanged: onFilterChanged,
            )
          : null,
      child: Column(
        children: [
          if (showCreateButton && onCreateRehearsal != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: onCreateRehearsal,
                icon: const Icon(Icons.add_circle_outline),
                label: Text(loc.rehearsalsNewButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const Gap(16),
          ],
          if (!isMediumScreen) ...[
            RehearsalFilterChips(
              currentFilter: currentFilter,
              onChanged: onFilterChanged,
            ),
            const Gap(16),
          ],
          if (rehearsals.isEmpty)
            const EmptyRehearsalsCard()
          else if (filtered.isEmpty)
            _EmptyFilterCard(filter: currentFilter)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const Gap(12),
              itemBuilder: (context, index) {
                final rehearsal = filtered[index];
                return RehearsalCard(
                  rehearsal: rehearsal,
                  onTap: () => onRehearsalTap(rehearsal),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _EmptyFilterCard extends StatelessWidget {
  const _EmptyFilterCard({required this.filter});

  final RehearsalFilter filter;

  @override
  Widget build(BuildContext context) {
    final label = switch (filter) {
      RehearsalFilter.upcoming => 'No hay ensayos próximos.',
      RehearsalFilter.past => 'Todavía no hay ensayos pasados.',
      RehearsalFilter.all => 'No hay ensayos para mostrar.',
    };
    return EmptyStateCard(
      icon: Icons.filter_alt_outlined,
      title: 'Sin resultados',
      subtitle: label,
    );
  }
}
