import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/musician_search_cubit.dart';
import '../../data/musicians_repository.dart';
import '../../domain/musician_entity.dart';
import '../widgets/musician_card.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../home/controllers/user_home_controller.dart';
import '../../../../home/ui/widgets/search/advanced_search_box.dart';

class MusicianSearchPage extends StatelessWidget {
  const MusicianSearchPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MusicianSearchCubit(repository: context.read<MusiciansRepository>())
            ..search(),
      child: MusicianSearchView(showAppBar: showAppBar),
    );
  }
}

class MusicianSearchView extends StatefulWidget {
  const MusicianSearchView({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<MusicianSearchView> createState() => _MusicianSearchViewState();
}

class _MusicianSearchViewState extends State<MusicianSearchView> {
  final _searchController = TextEditingController();
  late final UserHomeController _filters;

  @override
  void dispose() {
    _filters.removeListener(_onFiltersChanged);
    _filters.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _filters = UserHomeController()
      ..addListener(_onFiltersChanged)
      ..loadHome();
  }

  void _search() {
    context.read<MusicianSearchCubit>().search(
      query: _searchController.text.trim(),
    );
  }

  void _onFiltersChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: _TopSearchBar(
            controller: _searchController,
            onSubmitted: (_) => _search(),
            onPressed: _search,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;
              final filterWidth = isWide
                  ? constraints.maxWidth * 0.32
                  : constraints.maxWidth;

              final filterPanel = AnimatedBuilder(
                animation: _filters,
                builder: (context, _) {
                  final filtersReady = !_filters.isLoading;
                  final box = AdvancedSearchBox(
                    selectedInstrument: _filters.instrument,
                    selectedStyle: _filters.style,
                    selectedProfileType: _filters.profileType,
                    selectedGender: _filters.gender,
                    selectedProvince: _filters.province,
                    selectedCity: _filters.city,
                    provinces: _filters.provinces,
                    cities: _filters.cities,
                    onInstrumentChanged: _filters.selectInstrument,
                    onStyleChanged: _filters.selectStyle,
                    onProfileTypeChanged: _filters.selectProfileType,
                    onGenderChanged: _filters.selectGender,
                    onProvinceChanged: _filters.selectProvince,
                    onCityChanged: _filters.selectCity,
                    onSearch: filtersReady ? _search : null,
                  );

                  if (isWide) {
                    return box;
                  }

                  return Card(
                    margin: EdgeInsets.zero,
                    child: ExpansionTile(
                      title: const Text('Filtros avanzados'),
                      subtitle: const Text('Toca para ajustar los filtros'),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [box],
                    ),
                  );
                },
              );

              final resultsList =
                  BlocBuilder<MusicianSearchCubit, MusicianSearchState>(
                    builder: (context, state) {
                      if (state.isLoading || _filters.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.errorMessage != null) {
                        return Center(
                          child: Text(
                            state.errorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.redAccent),
                          ),
                        );
                      }
                      if (state.results.isEmpty) {
                        return const Center(
                          child: Text(
                            'No encontramos músicos con esos filtros.',
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          final MusicianEntity musician = state.results[index];
                          return MusicianCard(
                            musician: musician,
                            onTap: () => context.push(
                              AppRoutes.musicianDetail,
                              extra: musician,
                            ),
                          );
                        },
                      );
                    },
                  );

              if (!isWide) {
                final maxFilterHeight = constraints.maxHeight * 0.6;
                return Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxFilterHeight),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: SingleChildScrollView(child: filterPanel),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: resultsList,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  SizedBox(
                    width: filterWidth,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: filterPanel,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: resultsList,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );

    if (!widget.showAppBar) {
      return SafeArea(child: body);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar músicos')),
      body: body,
    );
  }
}

class _TopSearchBar extends StatelessWidget {
  const _TopSearchBar({
    required this.controller,
    required this.onSubmitted,
    required this.onPressed,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
