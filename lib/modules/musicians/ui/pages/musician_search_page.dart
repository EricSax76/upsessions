import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../cubits/musician_search_cubit.dart';
import '../../repositories/musicians_repository.dart';
import '../../models/musician_search_filters_controller.dart';

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
  late final MusicianSearchFiltersController _filters;

  @override
  void dispose() {
    _filters.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _filters = MusicianSearchFiltersController()..load();
  }

  void _search(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<MusicianSearchCubit>().search(
          query: _searchController.text.trim(),
          instrument: _filters.instrument,
          style: _filters.style,
          province: _filters.province,
          city: _filters.city,
          profileType: _filters.profileType,
          gender: _filters.gender,
        );
  }

  void _clearFilters(BuildContext context) {
    _searchController.clear();
    _filters.resetFilters();
    _search(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MusicianSearchCubit(repository: context.read<MusiciansRepository>())
            ..search(),
      child: Builder(builder: (context) {
        return MusicianSearchView(
          showAppBar: widget.showAppBar,
          searchController: _searchController,
          filters: _filters,
          onSearch: () => _search(context),
          onClearFilters: () => _clearFilters(context),
        );
      }),
    );
  }
}

class MusicianSearchView extends StatelessWidget {
  const MusicianSearchView({
    super.key,
    this.showAppBar = true,
    required this.searchController,
    required this.filters,
    required this.onSearch,
    required this.onClearFilters,
  });

  final bool showAppBar;
  final TextEditingController searchController;
  final MusicianSearchFiltersController filters;
  final VoidCallback onSearch;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final body = MusicianSearchLayout(
      topBar: MusicianSearchTopBar(
        controller: searchController,
        onSubmitted: (_) => onSearch(),
        onPressed: onSearch,
        filters: filters,
        onClearFilters: onClearFilters,
      ),
      filterPanelBuilder: (context, isWide) {
        return MusicianSearchFilterPanel(
          filters: filters,
          isWide: isWide,
          onSearch: onSearch,
          onClear: onClearFilters,
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
