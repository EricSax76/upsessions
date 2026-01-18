import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class FilterDropdown extends StatelessWidget {
  const FilterDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.displayLabel,
    this.placeholder = '',
  });

  final String label;
  final String hint;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String Function(String)? displayLabel;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final effectivePlaceholder =
        placeholder.isEmpty ? loc.searchUnassignedOption : placeholder;
    final normalizedOptions = options.contains(effectivePlaceholder)
        ? options
        : [effectivePlaceholder, ...options];
    final selectedValue = value.isNotEmpty && normalizedOptions.contains(value)
        ? value
        : effectivePlaceholder;

    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedValue,
      decoration: InputDecoration(labelText: label),
      hint: Text(hint),
      items: normalizedOptions
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(
                displayLabel?.call(option) ?? option,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (selected) {
        if (selected != null) {
          onChanged(selected == effectivePlaceholder ? '' : selected);
        }
      },
    );
  }
}
