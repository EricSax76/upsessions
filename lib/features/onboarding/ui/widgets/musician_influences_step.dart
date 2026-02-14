import 'package:flutter/material.dart';

import '../../../../core/locator/locator.dart';
import '../../../../core/constants/music_styles.dart';
import '../../../../modules/musicians/repositories/affinity_options_repository.dart';
import '../../logic/musician_onboarding_controller.dart';
import 'musician_onboarding_step_card.dart';

class MusicianInfluencesStep extends StatefulWidget {
  const MusicianInfluencesStep({super.key, required this.controller});

  final MusicianOnboardingController controller;

  @override
  State<MusicianInfluencesStep> createState() => _MusicianInfluencesStepState();
}

class _MusicianInfluencesStepState extends State<MusicianInfluencesStep> {
  final _artistController = TextEditingController();
  late final AffinityOptionsRepository _affinityOptionsRepository;
  String? _selectedStyle;
  List<String> _styleArtistOptions = const [];
  bool _loadingStyleOptions = false;
  int _loadRequestId = 0;

  @override
  void initState() {
    super.initState();
    _affinityOptionsRepository = locate<AffinityOptionsRepository>();
  }

  @override
  void dispose() {
    _artistController.dispose();
    super.dispose();
  }

  bool _isArtistSelected(String style, String artist) {
    final artists = widget.controller.influences[style] ?? const <String>[];
    return artists.any(
      (current) => current.toLowerCase() == artist.toLowerCase(),
    );
  }

  void _addInfluence({String? artistName}) {
    final style = _selectedStyle;
    final artist = (artistName ?? _artistController.text).trim();

    if (style != null && artist.isNotEmpty) {
      widget.controller.addInfluence(style, artist);
      setState(() {
        _artistController.clear();
      });
    }
  }

  List<String> _suggestedArtists() {
    final style = _selectedStyle;
    if (style == null) {
      return const [];
    }

    final options = _styleArtistOptions;
    if (options.isEmpty) {
      return const [];
    }

    final query = _artistController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return options;
    }

    return options
        .where((artist) => artist.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _onStyleChanged(String? style) async {
    final normalized = style?.trim();
    if (!mounted) {
      return;
    }

    if (normalized == null || normalized.isEmpty) {
      _loadRequestId++;
      setState(() {
        _selectedStyle = null;
        _artistController.clear();
        _styleArtistOptions = const [];
        _loadingStyleOptions = false;
      });
      return;
    }

    final requestId = ++_loadRequestId;
    setState(() {
      _selectedStyle = normalized;
      _artistController.clear();
      _styleArtistOptions = const [];
      _loadingStyleOptions = true;
    });

    final remoteOrFallback = await _affinityOptionsRepository
        .fetchArtistOptionsForStyle(normalized);
    if (!mounted || requestId != _loadRequestId) {
      return;
    }

    setState(() {
      _styleArtistOptions = remoteOrFallback;
      _loadingStyleOptions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestedArtists = _suggestedArtists();

    return Form(
      key: widget.controller.influencesKey,
      child: MusicianOnboardingStepCard(
        title: 'Tus influencias',
        description:
            'Agrega las bandas o artistas que más te han influenciado, organizados por estilo.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStyle,
                    decoration: const InputDecoration(
                      labelText: 'Estilo',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: musicStyles
                        .map(
                          (style) => DropdownMenuItem(
                            value: style,
                            child: Text(style, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: _onStyleChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _artistController,
                    decoration: const InputDecoration(
                      labelText: 'Artista / Banda',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) => _addInfluence(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addInfluence,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (_selectedStyle != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Opciones sugeridas',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 8),
              if (_loadingStyleOptions)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (suggestedArtists.isEmpty)
                Text(
                  'Sin coincidencias para este estilo.',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestedArtists
                      .map(
                        (artist) => FilterChip(
                          label: Text(artist),
                          selected: _isArtistSelected(_selectedStyle!, artist),
                          onSelected: (selected) {
                            if (_selectedStyle == null) {
                              return;
                            }
                            if (selected) {
                              _addInfluence(artistName: artist);
                              return;
                            }
                            widget.controller.removeInfluence(
                              _selectedStyle!,
                              artist,
                            );
                            setState(() {
                              _artistController.clear();
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
            ],
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                final influences = widget.controller.influences;
                if (influences.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Aún no has agregado influencias.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: influences.entries.map((entry) {
                    final style = entry.key;
                    final artists = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            style,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: artists
                                .map(
                                  (artist) => Chip(
                                    label: Text(artist),
                                    onDeleted: () {
                                      widget.controller.removeInfluence(
                                        style,
                                        artist,
                                      );
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
