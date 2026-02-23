part of 'advanced_search_box.dart';

class _AdvancedSearchCard extends StatelessWidget {
  const _AdvancedSearchCard({
    required this.selectedInstrument,
    required this.selectedStyle,
    required this.selectedProfileType,
    required this.selectedGender,
    required this.selectedProvince,
    required this.selectedCity,
    required this.provinces,
    required this.cities,
    required this.onInstrumentChanged,
    required this.onStyleChanged,
    required this.onProfileTypeChanged,
    required this.onGenderChanged,
    required this.onProvinceChanged,
    required this.onCityChanged,
    this.onSearch,
    this.onClear,
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
  final String? title;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        const contentPadding = EdgeInsets.all(16);

        final header = Text(
          title ?? loc.searchAdvancedTitle,
          style: Theme.of(context).textTheme.titleMedium,
        );

        final fields = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._buildFieldGroup(
              isCompact: isCompact,
              left: FilterDropdown(
                label: loc.searchInstrumentLabel,
                hint: loc.searchInstrumentHint,
                value: selectedInstrument,
                options: _instrumentOptions,
                onChanged: onInstrumentChanged,
              ),
              right: FilterDropdown(
                label: loc.searchStyleLabel,
                hint: loc.searchStyleHint,
                value: selectedStyle,
                options: _styleOptions,
                onChanged: onStyleChanged,
              ),
            ),
            ..._buildFieldGroup(
              isCompact: isCompact,
              left: FilterDropdown(
                label: loc.searchProfileTypeLabel,
                hint: loc.searchProfileTypeHint,
                value: selectedProfileType,
                options: _profileTypeOptions,
                onChanged: onProfileTypeChanged,
              ),
              right: GenderRadioGroup(
                value: selectedGender,
                onChanged: onGenderChanged,
              ),
            ),
            ..._buildFieldGroup(
              isCompact: isCompact,
              left: FilterDropdown(
                label: loc.searchProvinceLabel,
                hint: loc.searchProvinceHint,
                value: selectedProvince,
                options: provinces,
                onChanged: onProvinceChanged,
              ),
              right: FilterDropdown(
                label: loc.searchCityLabel,
                hint: cities.isNotEmpty
                    ? loc.searchCityHint
                    : loc.searchCityUnavailable,
                value: selectedCity,
                options: cities,
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
                  children: _buildActionsChildren(context, useWrapSpacing: true),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildActionsChildren(context, useWrapSpacing: false),
                ),
        );

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).dividerColor),
          ),
          child: Padding(
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
          ),
        );
      },
    );
  }

  List<Widget> _buildActionsChildren(
    BuildContext context, {
    required bool useWrapSpacing,
  }) {
    final loc = AppLocalizations.of(context);
    final clear = TextButton.icon(
      onPressed: onClear,
      icon: const Icon(Icons.filter_alt_off),
      label: Text(loc.searchClearFilters),
    );
    final search = FilledButton.icon(
      onPressed: onSearch,
      icon: const Icon(Icons.search),
      label: Text(loc.searchAction),
    );
    if (useWrapSpacing) {
      return [clear, search];
    }
    return [clear, const SizedBox(width: 8), search];
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
