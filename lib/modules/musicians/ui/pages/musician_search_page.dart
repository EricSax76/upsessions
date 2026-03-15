import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/home/repositories/home_metadata_repository.dart';

import '../../cubits/musician_search_cubit.dart';
import '../../repositories/musicians_repository.dart';
import '../widgets/search/musician_search_filter_panel.dart';
import '../widgets/search/musician_search_layout.dart';
import '../widgets/search/musician_search_results_list.dart';
import '../widgets/search/musician_search_top_bar.dart';

class MusicianSearchPage extends StatefulWidget {
  const MusicianSearchPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  State<MusicianSearchPage> createState() => _MusicianSearchPageState();
}

class _MusicianSearchPageState extends State<MusicianSearchPage> {
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
      child: MusicianSearchView(showAppBar: widget.showAppBar),
    );
  }
}

class MusicianSearchView extends StatelessWidget {
  const MusicianSearchView({super.key, this.showAppBar = true});

  final bool showAppBar;

  bool _isWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
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
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
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
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Filtros Avanzados',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
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
                            padding: const EdgeInsets.all(16),
                            child: MusicianSearchFilterPanel(
                              isWide: true,
                              onApplied: () => Navigator.pop(context),
                              onCleared: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: FilledButton(
                          onPressed: () {
                            cubit.searchNow();
                            Navigator.pop(context);
                          },
                          child: const Text('Aplicar Filtros'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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
        onFiltersPressed: () {
          if (_isWide(context)) {
            cubit.searchNow();
            return;
          }
          _showBottomFilters(context);
        },
      ),
      filterPanelBuilder: (context, isWide) {
        if (!isWide) {
          return const SizedBox.shrink();
        }
        return const MusicianSearchFilterPanel(isWide: true);
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
