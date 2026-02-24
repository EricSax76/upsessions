import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/home/repositories/home_metadata_repository.dart';

import '../../cubits/musician_search_cubit.dart';
import '../../repositories/musicians_repository.dart';

import '../widgets/search/musician_search_filter_panel.dart';
import '../widgets/search/musician_search_layout.dart';
import '../widgets/search/musician_search_results_list.dart';
import '../widgets/search/musician_search_top_bar.dart';
import '../../../../core/constants/app_routes.dart';

class MusicianSearchPage extends StatefulWidget {
  const MusicianSearchPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<MusicianSearchPage> createState() => _MusicianSearchPageState();
}

class _MusicianSearchPageState extends State<MusicianSearchPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _search(context);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _search(BuildContext context) {
    context.read<MusicianSearchCubit>().search(
      query: _searchController.text.trim(),
    );
  }

  void _clearFilters(BuildContext context) {
    _searchController.clear();
    context.read<MusicianSearchCubit>().clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MusicianSearchCubit(
              repository: locate<MusiciansRepository>(),
              metadataRepository: locate<HomeMetadataRepository>(),
            )
            ..loadFilters()
            ..search(),
      child: Builder(
        builder: (context) {
          return BlocBuilder<MusicianSearchCubit, MusicianSearchState>(
            builder: (context, state) {
              return MusicianSearchView(
                showAppBar: widget.showAppBar,
                searchController: _searchController,
                state: state,
                onSearch: () => _search(context),
                onClearFilters: () => _clearFilters(context),
              );
            },
          );
        },
      ),
    );
  }
}

class MusicianSearchView extends StatelessWidget {
  const MusicianSearchView({
    super.key,
    this.showAppBar = true,
    required this.searchController,
    required this.state,
    required this.onSearch,
    required this.onClearFilters,
  });

  final bool showAppBar;
  final TextEditingController searchController;
  final MusicianSearchState state;
  final VoidCallback onSearch;
  final VoidCallback onClearFilters;
  bool _isWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024; // Align with AdaptiveSearchLayout Breakpoints.desktop
  }

  void _showBottomFilters(BuildContext context) {
    final cubit = context.read<MusicianSearchCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: Builder(
            builder: (context) {
              return BlocBuilder<MusicianSearchCubit, MusicianSearchState>(
                builder: (context, sheetState) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.9,
                      minChildSize: 0.5,
                      maxChildSize: 0.9,
                      expand: false,
                      builder: (context, scrollController) {
                        return Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Filtros Avanzados',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: MusicianSearchFilterPanel(
                                      state: sheetState,
                                      isWide: true, // Force the column rendering
                                      onSearch: () {
                                        Navigator.pop(context);
                                        onSearch();
                                      },
                                      onClear: () {
                                        onClearFilters();
                                        Navigator.pop(context);
                                      },
                                      onInstrumentChanged: cubit.setInstrument,
                                      onStyleChanged: cubit.setStyle,
                                      onProfileTypeChanged: cubit.setProfileType,
                                      onGenderChanged: cubit.setGender,
                                      onProvinceChanged: cubit.setProvince,
                                      onCityChanged: cubit.setCity,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onSearch();
                                  },
                                  child: const Text('Aplicar Filtros'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MusicianSearchCubit>();

    final body = MusicianSearchLayout(
      topBar: MusicianSearchTopBar(
        controller: searchController,
        onSubmitted: (_) {}, // The debounce handles it 
        onPressed: () {
          if (_isWide(context)) {
             onSearch();
          } else {
             _showBottomFilters(context);
          }
        },
        state: state,
        onClearFilters: onClearFilters,
        onInstrumentChanged: cubit.setInstrument,
        onStyleChanged: cubit.setStyle,
        onProfileTypeChanged: cubit.setProfileType,
        onGenderChanged: cubit.setGender,
        onProvinceChanged: cubit.setProvince,
        onCityChanged: cubit.setCity,
      ),
      filterPanelBuilder: (context, isWide) {
        if (!isWide) return const SizedBox.shrink();
        
        return MusicianSearchFilterPanel(
          state: state,
          isWide: true,
          onSearch: onSearch,
          onClear: onClearFilters,
          onInstrumentChanged: cubit.setInstrument,
          onStyleChanged: cubit.setStyle,
          onProfileTypeChanged: cubit.setProfileType,
          onGenderChanged: cubit.setGender,
          onProvinceChanged: cubit.setProvince,
          onCityChanged: cubit.setCity,
        );
      },
      results: MusicianSearchResultsList(
        onTapMusician: (musician) => context.push(
          AppRoutes.musicianDetailPath(
            musicianId: musician.id,
            musicianName: musician.name,
          ),
          extra: musician,
        ),
      ),
    );

    if (!showAppBar) {
      return SafeArea(child: body);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar músicos')),
      body: body,
    );
  }
}
