import 'package:flutter/material.dart';

import 'city_dropdown.dart';
import 'gender_radio_group.dart';
import 'instrument_dropdown.dart';
import 'profile_type_dropdown.dart';
import 'province_dropdown.dart';
import 'style_dropdown.dart';

class AdvancedSearchBox extends StatelessWidget {
  const AdvancedSearchBox({
    super.key,
    required this.selectedInstrument,
    required this.selectedStyle,
    required this.selectedProfileType,
    required this.selectedGender,
    required this.selectedProvince,
    required this.selectedCity,
    required this.onInstrumentChanged,
    required this.onStyleChanged,
    required this.onProfileTypeChanged,
    required this.onGenderChanged,
    required this.onProvinceChanged,
    required this.onCityChanged,
  });

  final String selectedInstrument;
  final String selectedStyle;
  final String selectedProfileType;
  final String selectedGender;
  final String selectedProvince;
  final String selectedCity;
  final ValueChanged<String> onInstrumentChanged;
  final ValueChanged<String> onStyleChanged;
  final ValueChanged<String> onProfileTypeChanged;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onProvinceChanged;
  final ValueChanged<String> onCityChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Theme.of(context).dividerColor)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Búsqueda avanzada', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: InstrumentDropdown(value: selectedInstrument, onChanged: onInstrumentChanged)),
                const SizedBox(width: 12),
                Expanded(child: StyleDropdown(value: selectedStyle, onChanged: onStyleChanged)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ProfileTypeDropdown(value: selectedProfileType, onChanged: onProfileTypeChanged)),
                const SizedBox(width: 12),
                Expanded(child: GenderRadioGroup(value: selectedGender, onChanged: onGenderChanged)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: ProvinceDropdown(value: selectedProvince, onChanged: onProvinceChanged)),
                const SizedBox(width: 12),
                Expanded(child: CityDropdown(value: selectedCity, onChanged: onCityChanged)),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.search),
                label: const Text('Buscar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
