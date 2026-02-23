part of 'advanced_search_box.dart';

class _AdvancedSearchPopover extends StatelessWidget {
  const _AdvancedSearchPopover({
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
          title ?? loc.searchFiltersTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );

    final actions = Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        children: _buildActionsChildren(context),
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
                child: _buildFields(context, loc),
              ),
            ),
            const SizedBox(height: 12),
            actions,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionsChildren(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return [
      TextButton.icon(
        onPressed: onClear,
        icon: const Icon(Icons.filter_alt_off),
        label: Text(loc.searchClearFilters),
      ),
      FilledButton.icon(
        onPressed: onSearch,
        icon: const Icon(Icons.search),
        label: Text(loc.searchAction),
      ),
    ];
  }

  Widget _buildFields(BuildContext context, AppLocalizations loc) {
    const fieldWidth = 200.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: fieldWidth,
          child: FilterDropdown(
            label: loc.searchInstrumentLabel,
            hint: loc.searchInstrumentHint,
            value: selectedInstrument,
            options: _instrumentOptions,
            onChanged: onInstrumentChanged,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: fieldWidth,
          child: FilterDropdown(
            label: loc.searchStyleLabel,
            hint: loc.searchStyleHint,
            value: selectedStyle,
            options: _styleOptions,
            onChanged: onStyleChanged,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: fieldWidth,
          child: FilterDropdown(
            label: loc.searchProfileTypeLabel,
            hint: loc.searchProfileTypeHint,
            value: selectedProfileType,
            options: _profileTypeOptions,
            onChanged: onProfileTypeChanged,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: fieldWidth,
          child: FilterDropdown(
            label: loc.searchProvinceLabel,
            hint: loc.searchProvinceHint,
            value: selectedProvince,
            options: provinces,
            onChanged: onProvinceChanged,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: fieldWidth,
          child: FilterDropdown(
            label: loc.searchCityLabel,
            hint: cities.isNotEmpty
                ? loc.searchCityHint
                : loc.searchCityUnavailable,
            value: selectedCity,
            options: cities,
            onChanged: onCityChanged,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: fieldWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GenderRadioGroup(
                value: selectedGender,
                onChanged: onGenderChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
