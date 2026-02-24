import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../../core/widgets/forms/search_field.dart';
import '../../../cubits/musician_search_cubit.dart';

class MusicianSearchTopBar extends StatelessWidget {
  const MusicianSearchTopBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onPressed,
    this.state,
    this.onClearFilters,
    this.onInstrumentChanged,
    this.onStyleChanged,
    this.onProfileTypeChanged,
    this.onGenderChanged,
    this.onProvinceChanged,
    this.onCityChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onPressed;
  final MusicianSearchState? state;
  final VoidCallback? onClearFilters;
  final ValueChanged<String>? onInstrumentChanged;
  final ValueChanged<String>? onStyleChanged;
  final ValueChanged<String>? onProfileTypeChanged;
  final ValueChanged<String>? onGenderChanged;
  final ValueChanged<String>? onProvinceChanged;
  final ValueChanged<String>? onCityChanged;

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

    final activeFilters = state != null ? _activeFilterCount(state!) : 0;
    final hasFilters = activeFilters > 0;

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
                onSubmitted: onSubmitted,
                onChanged:
                    (
                      _,
                    ) {}, // The live search will be handled in the controller listener
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
          if (state != null)
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
                    onPressed:
                        onPressed, // In mobile, this will open the bottom sheet
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
