import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/music_styles.dart';

class MusicianInfluencesInputRow extends StatelessWidget {
  const MusicianInfluencesInputRow({
    super.key,
    required this.selectedStyle,
    required this.artistController,
    required this.onStyleChanged,
    required this.onArtistChanged,
    required this.onAddInfluence,
  });

  final String? selectedStyle;
  final TextEditingController artistController;
  final ValueChanged<String?> onStyleChanged;
  final ValueChanged<String> onArtistChanged;
  final VoidCallback onAddInfluence;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            initialValue: selectedStyle,
            decoration: InputDecoration(
              labelText: loc.affinityStyleLabel,
              contentPadding: const EdgeInsets.symmetric(
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
            onChanged: onStyleChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: artistController,
            decoration: InputDecoration(
              labelText: loc.affinityArtistBandLabel,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: onArtistChanged,
            onFieldSubmitted: (_) => onAddInfluence(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: onAddInfluence,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
