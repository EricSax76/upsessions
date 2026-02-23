import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../cubits/musician_search_cubit.dart';
import '../../../../../features/home/ui/widgets/search/advanced_search_box.dart';

class MusicianSearchFilterPanel extends StatelessWidget {
  const MusicianSearchFilterPanel({
    super.key,
    required this.state,
    required this.isWide,
    required this.onSearch,
    required this.onClear,
    required this.onInstrumentChanged,
    required this.onStyleChanged,
    required this.onProfileTypeChanged,
    required this.onGenderChanged,
    required this.onProvinceChanged,
    required this.onCityChanged,
  });

  final MusicianSearchState state;
  final bool isWide;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final ValueChanged<String> onInstrumentChanged;
  final ValueChanged<String> onStyleChanged;
  final ValueChanged<String> onProfileTypeChanged;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onProvinceChanged;
  final ValueChanged<String> onCityChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final hasActiveFilters =
        state.instrument.isNotEmpty ||
        state.style.isNotEmpty ||
        state.province.isNotEmpty ||
        state.city.isNotEmpty ||
        state.profileType.isNotEmpty ||
        state.gender.isNotEmpty;

    final box = AdvancedSearchBox(
      selectedInstrument: state.instrument,
      selectedStyle: state.style,
      selectedProfileType: state.profileType,
      selectedGender: state.gender,
      selectedProvince: state.province,
      selectedCity: state.city,
      provinces: state.provinces,
      cities: state.cities,
      onInstrumentChanged: onInstrumentChanged,
      onStyleChanged: onStyleChanged,
      onProfileTypeChanged: onProfileTypeChanged,
      onGenderChanged: onGenderChanged,
      onProvinceChanged: onProvinceChanged,
      onCityChanged: onCityChanged,
      onSearch: onSearch,
      onClear: onClear,
    );

    if (isWide) {
      return box
          .animate()
          .fade(duration: 400.ms, curve: Curves.easeOut)
          .slideY(
            begin: 0.1,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOutQuad,
          );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                loc.searchAdvancedFiltersTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                    duration: 1.seconds,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(0.8, 0.8),
                    duration: 1.seconds,
                    curve: Curves.easeInOut,
                  ),
            ],
          ],
        ),
        subtitle: Text(loc.searchAdvancedFiltersSubtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [box],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(
          begin: 0.2,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutBack,
        )
        .boxShadow(
          begin: const BoxShadow(color: Colors.transparent, blurRadius: 0),
          end: BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          duration: 500.ms,
          delay: 300.ms,
        );
  }
}
