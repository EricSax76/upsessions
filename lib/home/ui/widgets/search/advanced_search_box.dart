import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import 'filter_dropdown.dart';
import 'gender_radio_group.dart';

part 'advanced_search_card.dart';
part 'advanced_search_popover.dart';

const _instrumentOptions = <String>[
  'Voz',
  'Guitarra',
  'Bajo',
  'Batería',
  'Teclado',
  'Piano',
  'Saxofón',
  'Trompeta',
  'Violín',
  'Viola',
  'Violonchelo',
  'Contrabajo',
  'Flauta',
  'Clarinete',
  'Percusión',
  'DJ',
  'Producción',
];

const _styleOptions = <String>[
  'Rock',
  'Pop',
  'Indie',
  'Funk',
  'Soul',
  'R&B',
  'Jazz',
  'Blues',
  'Hip-Hop',
  'Rap',
  'Reggaetón',
  'Trap',
  'Electrónica',
  'House',
  'Techno',
  'Reggae',
  'Ska',
  'Punk',
  'Metal',
  'Clásica',
  'Flamenco',
  'Folklore',
  'Latino',
  'Salsa',
  'Bachata',
  'Country',
];

const _profileTypeOptions = <String>['Solista', 'Banda', 'Productor'];

enum AdvancedSearchBoxVariant { card, popover }

class AdvancedSearchBox extends StatelessWidget {
  const AdvancedSearchBox({
    super.key,
    required this.selectedInstrument,
    required this.selectedStyle,
    required this.selectedProfileType,
    required this.selectedGender,
    required this.selectedProvince,
    required this.selectedCity,
    required this.provinces,
    required this.cities,
    this.onSearch,
    this.onClear,
    required this.onInstrumentChanged,
    required this.onStyleChanged,
    required this.onProfileTypeChanged,
    required this.onGenderChanged,
    required this.onProvinceChanged,
    required this.onCityChanged,
    this.variant = AdvancedSearchBoxVariant.card,
    this.title,
  });

  final String selectedInstrument;
  final String selectedStyle;
  final String selectedProfileType;
  final String selectedGender;
  final String selectedProvince;
  final String selectedCity;
  final List<String> provinces;
  final List<String> cities;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;
  final ValueChanged<String> onInstrumentChanged;
  final ValueChanged<String> onStyleChanged;
  final ValueChanged<String> onProfileTypeChanged;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onProvinceChanged;
  final ValueChanged<String> onCityChanged;
  final AdvancedSearchBoxVariant variant;
  final String? title;

  @override
  Widget build(BuildContext context) {
    if (variant == AdvancedSearchBoxVariant.popover) {
      return _AdvancedSearchPopover(
        title: title,
        selectedInstrument: selectedInstrument,
        selectedStyle: selectedStyle,
        selectedProfileType: selectedProfileType,
        selectedGender: selectedGender,
        selectedProvince: selectedProvince,
        selectedCity: selectedCity,
        provinces: provinces,
        cities: cities,
        onSearch: onSearch,
        onClear: onClear,
        onInstrumentChanged: onInstrumentChanged,
        onStyleChanged: onStyleChanged,
        onProfileTypeChanged: onProfileTypeChanged,
        onGenderChanged: onGenderChanged,
        onProvinceChanged: onProvinceChanged,
        onCityChanged: onCityChanged,
      );
    }

    return _AdvancedSearchCard(
      title: title,
      selectedInstrument: selectedInstrument,
      selectedStyle: selectedStyle,
      selectedProfileType: selectedProfileType,
      selectedGender: selectedGender,
      selectedProvince: selectedProvince,
      selectedCity: selectedCity,
      provinces: provinces,
      cities: cities,
      onSearch: onSearch,
      onClear: onClear,
      onInstrumentChanged: onInstrumentChanged,
      onStyleChanged: onStyleChanged,
      onProfileTypeChanged: onProfileTypeChanged,
      onGenderChanged: onGenderChanged,
      onProvinceChanged: onProvinceChanged,
      onCityChanged: onCityChanged,
    );
  }
}
