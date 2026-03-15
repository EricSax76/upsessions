import 'package:flutter/material.dart';

import '../../../../core/widgets/gap.dart';
import '../../../../core/widgets/empty_state_card.dart';

import '../../../../l10n/app_localizations.dart';
import '../../models/rehearsal_entity.dart';
import '../../models/rehearsal_filter.dart';
import 'rehearsal_card.dart';
import 'rehearsal_filter_chips.dart';
import 'empty_rehearsals_card.dart';

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

    final createButton = showCreateButton && onCreateRehearsal != null
        ? FilledButton.icon(
            onPressed: onCreateRehearsal,
            icon: const Icon(Icons.add, size: 18),
            label: Text(loc.rehearsalsNewButton),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: colorScheme.secondary,
              foregroundColor: colorScheme.onSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.navRehearsals,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.rehearsalsPageSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isMediumScreen) ...[
              const Gap(16),
              RehearsalFilterChips(
                currentFilter: currentFilter,
                onChanged: onFilterChanged,
              ),
            ],
            if (createButton != null) ...[const Gap(16), createButton],
          ],
        ),
        const Gap(24),
        if (!isMediumScreen) ...[
          RehearsalFilterChips(
            currentFilter: currentFilter,
            onChanged: onFilterChanged,
          ),
          const Gap(24),
        ],
        if (rehearsals.isEmpty)
          const EmptyRehearsalsCard()
        else if (filtered.isEmpty)
          _EmptyFilterCard(filter: currentFilter)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              if (isWide) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final rehearsal = filtered[index];
                    return RehearsalCard(
                      rehearsal: rehearsal,
                      onTap: () => onRehearsalTap(rehearsal),
                    );
                  },
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const Gap(20),
                itemBuilder: (context, index) {
                  final rehearsal = filtered[index];
                  return RehearsalCard(
                    rehearsal: rehearsal,
                    onTap: () => onRehearsalTap(rehearsal),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

class _EmptyFilterCard extends StatelessWidget {
  const _EmptyFilterCard({required this.filter});

  final RehearsalFilter filter;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final label = switch (filter) {
      RehearsalFilter.upcoming => loc.rehearsalsFilterEmptyUpcoming,
      RehearsalFilter.past => loc.rehearsalsFilterEmptyPast,
      RehearsalFilter.all => loc.rehearsalsFilterEmptyAll,
    };
    return EmptyStateCard(
      icon: Icons.filter_alt_outlined,
      title: loc.rehearsalsFilterEmptyTitle,
      subtitle: label,
    );
  }
}
