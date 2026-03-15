import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../../core/widgets/forms/search_field.dart';
import '../../../cubits/musician_search_cubit.dart';

class MusicianSearchTopBar extends StatelessWidget {
  const MusicianSearchTopBar({
    super.key,
    required this.controller,
    required this.onFiltersPressed,
  });

  final TextEditingController controller;
  final VoidCallback onFiltersPressed;

  int _activeFilterCount(MusicianSearchState state) {
    var count = 0;
    if (state.instrument.isNotEmpty) count++;
    if (state.style.isNotEmpty) count++;
    if (state.profileType.isNotEmpty) count++;
    if (state.gender.isNotEmpty) count++;
    if (state.province.isNotEmpty) count++;
    if (state.city.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = context.watch<MusicianSearchCubit>().state;
    final activeFilters = _activeFilterCount(state);
    final hasFilters = activeFilters > 0;
    final cubit = context.read<MusicianSearchCubit>();
    if (controller.text != state.query) {
      controller.value = TextEditingValue(
        text: state.query,
        selection: TextSelection.collapsed(offset: state.query.length),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SearchField(
                controller: controller,
                hintText: loc.searchTopBarHint,
                onSubmitted: (value) => cubit.searchNow(query: value),
                onChanged: cubit.onQueryChanged,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  color: hasFilters
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  onPressed: onFiltersPressed,
                  tooltip: 'Filtros avanzados',
                ),
                if (hasFilters)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
