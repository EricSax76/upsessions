import 'package:flutter/material.dart';

import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/core/constants/music_styles.dart';
import 'package:upsessions/modules/auth/models/profile_entity.dart';
import 'package:upsessions/modules/musicians/repositories/affinity_options_repository.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key, required this.profile, required this.onSave});

  final ProfileEntity profile;
  final ValueChanged<ProfileEntity> onSave;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late final TextEditingController _artistController;
  late final AffinityOptionsRepository _affinityOptionsRepository;
  late Map<String, List<String>> _influences;
  String? _selectedStyle;
  List<String> _styleArtistOptions = const [];
  bool _loadingStyleOptions = false;
  int _loadRequestId = 0;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.profile.bio);
    _locationController = TextEditingController(text: widget.profile.location);
    _artistController = TextEditingController();
    _affinityOptionsRepository = locate<AffinityOptionsRepository>();
    _influences = _cloneInfluences(widget.profile.influences);
  }

  @override
  void didUpdateWidget(covariant ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile == widget.profile) {
      return;
    }

    _bioController.text = widget.profile.bio;
    _locationController.text = widget.profile.location;
    _influences = _cloneInfluences(widget.profile.influences);
    _loadRequestId++;
    _selectedStyle = null;
    _artistController.clear();
    _styleArtistOptions = const [];
    _loadingStyleOptions = false;
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  static Map<String, List<String>> _cloneInfluences(
    Map<String, List<String>> source,
  ) {
    return source.map(
      (style, artists) => MapEntry(style, List<String>.from(artists)),
    );
  }

  bool _isArtistSelected(String style, String artist) {
    final artists = _influences[style] ?? const <String>[];
    return artists.any(
      (current) => current.toLowerCase() == artist.toLowerCase(),
    );
  }

  void _addInfluence({String? artistName}) {
    final style = _selectedStyle;
    final artist = (artistName ?? _artistController.text).trim();
    if (style == null || artist.isEmpty) {
      return;
    }

    final artists = List<String>.from(_influences[style] ?? const <String>[]);
    final alreadyExists = artists.any(
      (current) => current.toLowerCase() == artist.toLowerCase(),
    );
    if (alreadyExists) {
      return;
    }

    setState(() {
      artists.add(artist);
      _influences[style] = artists;
      _artistController.clear();
    });
  }

  void _removeInfluence(String style, String artist) {
    setState(() {
      final artists = List<String>.from(_influences[style] ?? const <String>[]);
      artists.remove(artist);
      if (artists.isEmpty) {
        _influences.remove(style);
      } else {
        _influences[style] = artists;
      }
    });
  }

  void _save() {
    widget.onSave(
      widget.profile.copyWith(
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        influences: _cloneInfluences(_influences),
      ),
    );
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

  Widget _buildInfluenceInputs() {
    final suggestedArtists = _suggestedArtists();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;
        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedStyle,
                decoration: const InputDecoration(labelText: 'Estilo'),
                items: musicStyles
                    .map(
                      (style) =>
                          DropdownMenuItem(value: style, child: Text(style)),
                    )
                    .toList(),
                onChanged: _onStyleChanged,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _artistController,
                decoration: const InputDecoration(labelText: 'Artista / Banda'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _addInfluence(),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _addInfluence,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ),
              if (_selectedStyle != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Opciones sugeridas',
                  style: Theme.of(context).textTheme.labelLarge,
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
                            selected: _isArtistSelected(
                              _selectedStyle!,
                              artist,
                            ),
                            onSelected: (selected) {
                              if (_selectedStyle == null) {
                                return;
                              }
                              if (selected) {
                                _addInfluence(artistName: artist);
                                return;
                              }
                              _removeInfluence(_selectedStyle!, artist);
                              setState(() {
                                _artistController.clear();
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
              ],
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStyle,
                    decoration: const InputDecoration(labelText: 'Estilo'),
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
                  child: TextField(
                    controller: _artistController,
                    decoration: const InputDecoration(
                      labelText: 'Artista / Banda',
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _addInfluence(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addInfluence,
                  icon: const Icon(Icons.add),
                  tooltip: 'Agregar afinidad',
                ),
              ],
            ),
            if (_selectedStyle != null) ...[
              const SizedBox(height: 12),
              Text(
                'Opciones sugeridas',
                style: Theme.of(context).textTheme.labelLarge,
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
                            _removeInfluence(_selectedStyle!, artist);
                            setState(() {
                              _artistController.clear();
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _influences.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _bioController,
            decoration: const InputDecoration(labelText: 'Biografía'),
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Ubicación'),
          ),
          const SizedBox(height: 24),
          Text(
            'Afinidades musicales',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega o quita artistas que representen tus influencias por estilo.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          _buildInfluenceInputs(),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Text(
              'Sin afinidades registradas.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.map((entry) {
                final style = entry.key;
                final artists = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        style,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
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
                                onDeleted: () =>
                                    _removeInfluence(style, artist),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Guardar cambios'),
            ),
          ),
        ],
      ),
    );
  }
}
