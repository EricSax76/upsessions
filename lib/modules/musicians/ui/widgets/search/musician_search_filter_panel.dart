import 'package:flutter/material.dart';

import '../../../models/musician_search_filters_controller.dart';
import '../../../../../home/ui/widgets/search/advanced_search_box.dart';

class MusicianSearchFilterPanel extends StatelessWidget {
  const MusicianSearchFilterPanel({
    super.key,
    required this.filters,
    required this.isWide,
    required this.onSearch,
    required this.onClear,
  });

  final MusicianSearchFiltersController filters;
  final bool isWide;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: filters,
      builder: (context, _) {
        final filtersReady = !filters.isLoading;
        final box = AdvancedSearchBox(
          selectedInstrument: filters.instrument,
          selectedStyle: filters.style,
          selectedProfileType: filters.profileType,
          selectedGender: filters.gender,
          selectedProvince: filters.province,
          selectedCity: filters.city,
          provinces: filters.provinces,
          cities: filters.cities,
          onInstrumentChanged: filters.selectInstrument,
          onStyleChanged: filters.selectStyle,
          onProfileTypeChanged: filters.selectProfileType,
          onGenderChanged: filters.selectGender,
          onProvinceChanged: filters.selectProvince,
          onCityChanged: filters.selectCity,
          onSearch: filtersReady ? onSearch : null,
          onClear: filtersReady ? onClear : null,
        );

        if (isWide) {
          return box;
        }

        return Card(
          margin: EdgeInsets.zero,
          child: ExpansionTile(
            title: const Text('Filtros avanzados'),
            subtitle: const Text('Toca para ajustar los filtros'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [box],
          ),
        );
      },
    );
  }
}
