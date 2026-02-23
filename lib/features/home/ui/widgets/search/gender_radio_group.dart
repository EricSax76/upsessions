import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class GenderRadioGroup extends StatelessWidget {
  const GenderRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const _options = [
    'Sin asignar',
    'Cualquiera',
    'Femenino',
    'Masculino',
  ];

  String _labelForOption(String option, AppLocalizations loc) {
    switch (option) {
      case 'Sin asignar':
        return loc.searchUnassignedOption;
      case 'Cualquiera':
        return loc.searchAnyOption;
      case 'Femenino':
        return loc.searchFemaleOption;
      case 'Masculino':
        return loc.searchMaleOption;
    }
    return option;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final selectedValue = value.isNotEmpty && _options.contains(value)
        ? value
        : _options.first;
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedValue,
      decoration: InputDecoration(labelText: loc.searchGenderLabel),
      hint: Text(loc.searchGenderHint),
      items: _options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(
                _labelForOption(option, loc),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected == _options.first ? '' : selected);
        }
      },
    );
  }
}
