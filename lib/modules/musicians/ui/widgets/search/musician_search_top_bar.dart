import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../../core/widgets/forms/search_field.dart';
import '../../../cubits/musician_search_cubit.dart';
import '../../../../../home/ui/widgets/search/advanced_search_box.dart';

class MusicianSearchTopBar extends StatelessWidget {
  const MusicianSearchTopBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onPressed,
    this.state,
    this.onClearFilters,
    this.onInstrumentChanged,
    this.onStyleChanged,
    this.onProfileTypeChanged,
    this.onGenderChanged,
    this.onProvinceChanged,
    this.onCityChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onPressed;
  final MusicianSearchState? state;
  final VoidCallback? onClearFilters;
  final ValueChanged<String>? onInstrumentChanged;
  final ValueChanged<String>? onStyleChanged;
  final ValueChanged<String>? onProfileTypeChanged;
  final ValueChanged<String>? onGenderChanged;
  final ValueChanged<String>? onProvinceChanged;
  final ValueChanged<String>? onCityChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final showWebFilters = kIsWeb && state != null && onClearFilters != null;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: SearchField(
                controller: controller,
                hintText: loc.searchTopBarHint,
                onSubmitted: onSubmitted,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            const SizedBox(width: 8),
            if (showWebFilters) ...[
              _WebFiltersMenu(
                state: state!,
                onSearch: onPressed,
                onClear: onClearFilters!,
                onInstrumentChanged: onInstrumentChanged!,
                onStyleChanged: onStyleChanged!,
                onProfileTypeChanged: onProfileTypeChanged!,
                onGenderChanged: onGenderChanged!,
                onProvinceChanged: onProvinceChanged!,
                onCityChanged: onCityChanged!,
              ),
              const SizedBox(width: 8),
            ],
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text(loc.searchAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebFiltersMenu extends StatefulWidget {
  const _WebFiltersMenu({
    required this.state,
    required this.onSearch,
    required this.onClear,
    required this.onInstrumentChanged,
    required this.onStyleChanged,
    required this.onProfileTypeChanged,
    required this.onGenderChanged,
    required this.onProvinceChanged,
    required this.onCityChanged,
  });

  final MusicianSearchState state;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final ValueChanged<String> onInstrumentChanged;
  final ValueChanged<String> onStyleChanged;
  final ValueChanged<String> onProfileTypeChanged;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<String> onProvinceChanged;
  final ValueChanged<String> onCityChanged;

  @override
  State<_WebFiltersMenu> createState() => _WebFiltersMenuState();
}

class _WebFiltersMenuState extends State<_WebFiltersMenu> {
  final MenuController _menuController = MenuController();

  void _defer(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  int _activeFilterCount(MusicianSearchState state) {
    var count = 0;
    if (state.instrument.isNotEmpty) count++;
    if (state.style.isNotEmpty) count++;
    if (state.profileType.isNotEmpty) count++;
    if (state.gender.isNotEmpty) count++;
    if (state.province.isNotEmpty) count++;
    if (state.city.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final filtersReady = !widget.state.areFiltersLoading;
    final activeCount = _activeFilterCount(widget.state);
    final label = activeCount == 0
        ? loc.searchFiltersTitle
        : loc.searchFiltersWithCount(activeCount);

    return MenuAnchor(
      controller: _menuController,
      menuChildren: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            child: AdvancedSearchBox(
              variant: AdvancedSearchBoxVariant.popover,
              selectedInstrument: widget.state.instrument,
              selectedStyle: widget.state.style,
              selectedProfileType: widget.state.profileType,
              selectedGender: widget.state.gender,
              selectedProvince: widget.state.province,
              selectedCity: widget.state.city,
              provinces: widget.state.provinces,
              cities: widget.state.cities,
              onInstrumentChanged: widget.onInstrumentChanged,
              onStyleChanged: widget.onStyleChanged,
              onProfileTypeChanged: widget.onProfileTypeChanged,
              onGenderChanged: widget.onGenderChanged,
              onProvinceChanged: widget.onProvinceChanged,
              onCityChanged: widget.onCityChanged,
              onSearch: filtersReady
                  ? () {
                      widget.onSearch();
                      _defer(_menuController.close);
                    }
                  : null,
              onClear: filtersReady
                  ? () {
                      widget.onClear();
                      _defer(_menuController.close);
                    }
                  : null,
            ),
          ),
        ),
      ],
      builder: (context, controller, child) {
        return OutlinedButton.icon(
          onPressed: () => _defer(
            () => controller.isOpen ? controller.close() : controller.open(),
          ),
          icon: const Icon(Icons.tune),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        );
      },
    );
  }
}
