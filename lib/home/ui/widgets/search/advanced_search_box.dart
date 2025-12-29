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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Búsqueda avanzada',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                ..._buildFieldGroup(
                  isCompact: isCompact,
                  left: InstrumentDropdown(
                    value: selectedInstrument,
                    onChanged: onInstrumentChanged,
                  ),
                  right: StyleDropdown(
                    value: selectedStyle,
                    onChanged: onStyleChanged,
                  ),
                ),
                ..._buildFieldGroup(
                  isCompact: isCompact,
                  left: ProfileTypeDropdown(
                    value: selectedProfileType,
                    onChanged: onProfileTypeChanged,
                  ),
                  right: GenderRadioGroup(
                    value: selectedGender,
                    onChanged: onGenderChanged,
                  ),
                ),
                ..._buildFieldGroup(
                  isCompact: isCompact,
                  left: ProvinceDropdown(
                    value: selectedProvince,
                    provinces: provinces,
                    onChanged: onProvinceChanged,
                  ),
                  right: CityDropdown(
                    value: selectedCity,
                    cities: cities,
                    onChanged: onCityChanged,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: isCompact
                      ? Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TextButton.icon(
                              onPressed: onClear,
                              icon: const Icon(Icons.filter_alt_off),
                              label: const Text('Quitar filtros'),
                            ),
                            FilledButton.icon(
                              onPressed: onSearch,
                              icon: const Icon(Icons.search),
                              label: const Text('Buscar'),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: onClear,
                              icon: const Icon(Icons.filter_alt_off),
                              label: const Text('Quitar filtros'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: onSearch,
                              icon: const Icon(Icons.search),
                              label: const Text('Buscar'),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFieldGroup({
    required bool isCompact,
    required Widget left,
    required Widget right,
  }) {
    if (isCompact) {
      return [
        left,
        const SizedBox(height: 12),
        right,
        const SizedBox(height: 12),
      ];
    }
    return [
      Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
      const SizedBox(height: 12),
    ];
  }
}
