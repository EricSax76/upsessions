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

  void _search() {
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

  void _clearFilters() {
    _searchController.clear();
    _filters.resetFilters();
    _search();
  }

  @override
  Widget build(BuildContext context) {
    final body = MusicianSearchLayout(
      topBar: MusicianSearchTopBar(
        controller: _searchController,
        onSubmitted: (_) => _search(),
        onPressed: _search,
      ),
      filterPanelBuilder: (context, isWide) {
        return MusicianSearchFilterPanel(
          filters: _filters,
          isWide: isWide,
          onSearch: _search,
          onClear: _clearFilters,
        );
      },
      results: MusicianSearchResultsList(
        onTapMusician: (musician) =>
            context.push(AppRoutes.musicianDetail, extra: musician),
      ),
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
