import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../cubits/musician_search_cubit.dart';
import '../../../../../home/ui/widgets/search/advanced_search_box.dart';

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
      return box;
    }

    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(loc.searchAdvancedFiltersTitle),
        subtitle: Text(loc.searchAdvancedFiltersSubtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [box],
      ),
    );
  }
}
