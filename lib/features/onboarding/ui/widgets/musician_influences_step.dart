import 'package:flutter/material.dart';

import '../../../../core/constants/music_styles.dart';
import '../../models/musician_onboarding_controller.dart';
import 'musician_onboarding_step_card.dart';

class MusicianInfluencesStep extends StatefulWidget {
  const MusicianInfluencesStep({super.key, required this.controller});

  final MusicianOnboardingController controller;

  @override
  State<MusicianInfluencesStep> createState() => _MusicianInfluencesStepState();
}

class _MusicianInfluencesStepState extends State<MusicianInfluencesStep> {
  final _artistController = TextEditingController();
  String? _selectedStyle;

  @override
  void dispose() {
    _artistController.dispose();
    super.dispose();
  }

  void _addInfluence() {
    final style = _selectedStyle;
    final artist = _artistController.text.trim();

    if (style != null && artist.isNotEmpty) {
      widget.controller.addInfluence(style, artist);
      _artistController.clear();
      setState(() {
        _selectedStyle = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: musicStyles
                        .map(
                          (style) => DropdownMenuItem(
                            value: style,
                            child: Text(style, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStyle = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _artistController,
                    decoration: const InputDecoration(
                      labelText: 'Artista / Banda',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
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
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                                      widget.controller.removeInfluence(style, artist);
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
