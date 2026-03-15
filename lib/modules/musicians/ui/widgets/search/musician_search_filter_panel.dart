import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/musician_search_cubit.dart';
import '../../../../../features/home/ui/widgets/search/advanced_search_box.dart';

class MusicianSearchFilterPanel extends StatelessWidget {
  const MusicianSearchFilterPanel({
    super.key,
    required this.isWide,
    this.onApplied,
    this.onCleared,
  });

  final bool isWide;
  final VoidCallback? onApplied;
  final VoidCallback? onCleared;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MusicianSearchCubit>();
    final state = context.watch<MusicianSearchCubit>().state;

    final box = AdvancedSearchBox(
      selectedInstrument: state.instrument,
      selectedStyle: state.style,
      selectedProfileType: state.profileType,
      selectedGender: state.gender,
      selectedProvince: state.province,
      selectedCity: state.city,
      provinces: state.provinces,
      cities: state.cities,
      onInstrumentChanged: cubit.setInstrument,
      onStyleChanged: cubit.setStyle,
      onProfileTypeChanged: cubit.setProfileType,
      onGenderChanged: cubit.setGender,
      onProvinceChanged: cubit.setProvince,
      onCityChanged: cubit.setCity,
      onSearch: () async {
        await cubit.searchNow();
        onApplied?.call();
      },
      onClear: () async {
        await cubit.clearFilters();
        onCleared?.call();
      },
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
