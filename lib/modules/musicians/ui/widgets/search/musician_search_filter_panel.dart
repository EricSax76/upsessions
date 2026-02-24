import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

    return box;
  }
}
