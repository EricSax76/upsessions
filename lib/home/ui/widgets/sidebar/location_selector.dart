import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class LocationSelector extends StatelessWidget {
  const LocationSelector({
    super.key,
    required this.province,
    required this.city,
    required this.provinces,
    required this.cities,
    required this.onProvinceChanged,
    required this.onCityChanged,
  });

  final String province;
  final String city;
  final List<String> provinces;
  final List<String> cities;
  final ValueChanged<String> onProvinceChanged;
  final ValueChanged<String> onCityChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final hasProvinces = provinces.isNotEmpty;
    final hasCities = cities.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue:
              hasProvinces && provinces.contains(province) ? province : null,
          decoration: InputDecoration(labelText: loc.searchProvinceLabel),
          hint: Text(loc.searchProvinceHint),
          items: provinces.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: hasProvinces
              ? (selected) {
                  if (selected != null) {
                    onProvinceChanged(selected);
                  }
                }
              : null,
        ),
        if (!hasProvinces) ...[
          const SizedBox(height: 8),
          Text(
            loc.searchProvincesLoadHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: hasCities && cities.contains(city) ? city : null,
          decoration: InputDecoration(labelText: loc.searchCityLabel),
          hint: Text(
            hasProvinces ? loc.searchCityHint : loc.searchCityUnavailable,
          ),
          items: cities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: hasCities
              ? (selected) {
                  if (selected != null) {
                    onCityChanged(selected);
                  }
                }
              : null,
        ),
        if (!hasCities) ...[
          const SizedBox(height: 8),
          Text(
            loc.searchCitiesLoadHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
