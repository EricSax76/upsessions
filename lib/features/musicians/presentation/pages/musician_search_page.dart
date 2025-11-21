import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/musician_search_cubit.dart';
import '../../data/musicians_repository.dart';
import '../../domain/musician_entity.dart';
import '../widgets/musician_card.dart';
import '../widgets/musician_filter_panel.dart';
import '../widgets/musician_filters_chip_row.dart';
import 'musician_detail_page.dart';

class MusicianSearchPage extends StatelessWidget {
  const MusicianSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MusicianSearchCubit(repository: context.read<MusiciansRepository>())..search(),
      child: const _MusicianSearchView(),
    );
  }
}

class _MusicianSearchView extends StatefulWidget {
  const _MusicianSearchView();

  @override
  State<_MusicianSearchView> createState() => _MusicianSearchViewState();
}

class _MusicianSearchViewState extends State<_MusicianSearchView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    context.read<MusicianSearchCubit>().search(query: _searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar músicos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MusicianFilterPanel(controller: _searchController, onSearch: _search),
            const SizedBox(height: 12),
            MusicianFiltersChipRow(onChanged: (_) => _search()),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<MusicianSearchCubit, MusicianSearchState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.errorMessage != null) {
                    return Center(
                      child: Text(
                        state.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                      ),
                    );
                  }
                  if (state.results.isEmpty) {
                    return const Center(child: Text('No encontramos músicos con esos filtros.'));
                  }
                  return ListView.builder(
                    itemCount: state.results.length,
                    itemBuilder: (context, index) {
                      final MusicianEntity musician = state.results[index];
                      return MusicianCard(
                        musician: musician,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MusicianDetailPage(musician: musician)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
