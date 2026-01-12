import 'package:flutter/material.dart';

import 'city_dropdown.dart';
import 'gender_radio_group.dart';
import 'instrument_dropdown.dart';
import 'profile_type_dropdown.dart';
import 'province_dropdown.dart';
import 'style_dropdown.dart';

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
      return _buildPopoverContent(context);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final contentPadding = const EdgeInsets.all(16);

        final header = Text(
          title ?? 'Búsqueda avanzada',
          style: Theme.of(context).textTheme.titleMedium,
        );

        final fields = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          ],
        );

        final actions = Align(
          alignment: Alignment.centerRight,
          child: isCompact
              ? Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildActionsChildren(useWrapSpacing: true),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildActionsChildren(useWrapSpacing: false),
                ),
        );

        final content = Padding(
          padding: contentPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 12),
              fields,
              const SizedBox(height: 12),
              actions,
            ],
          ),
        );

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: content,
        );
      },
    );
  }

  Widget _buildPopoverContent(BuildContext context) {
    const contentPadding = EdgeInsets.fromLTRB(12, 12, 12, 12);

    final header = Row(
      children: [
        Icon(
          Icons.tune,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          title ?? 'Filtros',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );

    final fields = _buildPopoverFields(context);

    final actions = Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: _buildActionsChildren(useWrapSpacing: true),
      ),
    );

    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: contentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: fields,
              ),
            ),
            const SizedBox(height: 12),
            actions,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionsChildren({required bool useWrapSpacing}) {
    final clear = TextButton.icon(
      onPressed: onClear,
      icon: const Icon(Icons.filter_alt_off),
      label: const Text('Quitar filtros'),
    );
    final search = FilledButton.icon(
      onPressed: onSearch,
      icon: const Icon(Icons.search),
      label: const Text('Buscar'),
    );
    if (useWrapSpacing) {
      return [clear, search];
    }
    return [clear, const SizedBox(width: 8), search];
  }

  Widget _buildPopoverFields(BuildContext context) {
    const fieldWidth = 200.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: fieldWidth,
          child: InstrumentDropdown(
            value: selectedInstrument,
            onChanged: onInstrumentChanged,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: fieldWidth,
          child: StyleDropdown(value: selectedStyle, onChanged: onStyleChanged),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: fieldWidth,
          child: ProfileTypeDropdown(
            value: selectedProfileType,
            onChanged: onProfileTypeChanged,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: fieldWidth,
          child: ProvinceDropdown(
            value: selectedProvince,
            provinces: provinces,
            onChanged: onProvinceChanged,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: fieldWidth,
          child: CityDropdown(
            value: selectedCity,
            cities: cities,
            onChanged: onCityChanged,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: fieldWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenderRadioGroup(value: selectedGender, onChanged: onGenderChanged),
            ],
          ),
        ),
      ],
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
