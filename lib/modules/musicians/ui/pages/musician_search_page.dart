import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/home/repositories/user_home_repository.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(BuildContext context) {
    FocusScope.of(context).unfocus();
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
      create: (context) => MusicianSearchCubit(
        repository: locate<MusiciansRepository>(),
        userHomeRepository: locate<UserHomeRepository>(),
      )
        ..loadFilters()
        ..search(),
      child: Builder(builder: (context) {
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
      }),
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MusicianSearchCubit>();

    final body = MusicianSearchLayout(
      topBar: MusicianSearchTopBar(
        controller: searchController,
        onSubmitted: (_) => onSearch(),
        onPressed: onSearch,
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
        return MusicianSearchFilterPanel(
          state: state,
          isWide: isWide,
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
