import 'package:flutter/material.dart';

import '../../data/musicians_repository.dart';
import '../../domain/musician_entity.dart';
import '../widgets/musician_card.dart';
import '../widgets/musician_filter_panel.dart';
import '../widgets/musician_filters_chip_row.dart';
import 'musician_detail_page.dart';

class MusicianSearchPage extends StatefulWidget {
  const MusicianSearchPage({super.key});

  @override
  State<MusicianSearchPage> createState() => _MusicianSearchPageState();
}

class _MusicianSearchPageState extends State<MusicianSearchPage> {
  final _searchController = TextEditingController();
  final MusiciansRepository _repository = MusiciansRepository();
  List<MusicianEntity> _results = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() => _loading = true);
    _results = await _repository.search(query: _searchController.text);
    setState(() => _loading = false);
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final musician = _results[index];
                        return MusicianCard(
                          musician: musician,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => MusicianDetailPage(musician: musician)),
                          ),
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
