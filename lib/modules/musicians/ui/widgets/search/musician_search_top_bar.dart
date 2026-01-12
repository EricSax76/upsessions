import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../models/musician_search_filters_controller.dart';
import '../../../../../home/ui/widgets/search/advanced_search_box.dart';

class MusicianSearchTopBar extends StatelessWidget {
  const MusicianSearchTopBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onPressed,
    this.filters,
    this.onClearFilters,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onPressed;
  final MusicianSearchFiltersController? filters;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final showWebFilters = kIsWeb && filters != null && onClearFilters != null;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Busca por nombre, estilo o instrumento',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (showWebFilters) ...[
              _WebFiltersMenu(
                filters: filters!,
                onSearch: onPressed,
                onClear: onClearFilters!,
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
              child: const Text('Buscar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebFiltersMenu extends StatefulWidget {
  const _WebFiltersMenu({
    required this.filters,
    required this.onSearch,
    required this.onClear,
  });

  final MusicianSearchFiltersController filters;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  @override
  State<_WebFiltersMenu> createState() => _WebFiltersMenuState();
}

class _WebFiltersMenuState extends State<_WebFiltersMenu> {
  final MenuController _menuController = MenuController();

  void _defer(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  int _activeFilterCount(MusicianSearchFiltersController filters) {
    var count = 0;
    if (filters.instrument.isNotEmpty) count++;
    if (filters.style.isNotEmpty) count++;
    if (filters.profileType.isNotEmpty) count++;
    if (filters.gender.isNotEmpty) count++;
    if (filters.province.isNotEmpty) count++;
    if (filters.city.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.filters,
      builder: (context, _) {
        final filtersReady = !widget.filters.isLoading;
        final activeCount = _activeFilterCount(widget.filters);
        final label = activeCount == 0 ? 'Filtros' : 'Filtros ($activeCount)';

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
                  selectedInstrument: widget.filters.instrument,
                  selectedStyle: widget.filters.style,
                  selectedProfileType: widget.filters.profileType,
                  selectedGender: widget.filters.gender,
                  selectedProvince: widget.filters.province,
                  selectedCity: widget.filters.city,
                  provinces: widget.filters.provinces,
                  cities: widget.filters.cities,
                  onInstrumentChanged: widget.filters.selectInstrument,
                  onStyleChanged: widget.filters.selectStyle,
                  onProfileTypeChanged: widget.filters.selectProfileType,
                  onGenderChanged: widget.filters.selectGender,
                  onProvinceChanged: widget.filters.selectProvince,
                  onCityChanged: widget.filters.selectCity,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            );
          },
        );
      },
    );
  }
}
