import 'package:flutter/material.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../../../core/constants/app_spacing.dart';
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            initialValue: selectedStyle,
            isExpanded: true,
            decoration: InputDecoration(labelText: loc.affinityStyleLabel),
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
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: artistController,
            decoration: InputDecoration(labelText: loc.affinityArtistBandLabel),
            onChanged: onArtistChanged,
            onFieldSubmitted: (_) => onAddInfluence(),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Tooltip(
          message: loc.affinityAddTooltip,
          child: FilledButton.tonal(
            onPressed: onAddInfluence,
            style: FilledButton.styleFrom(
              minimumSize: const Size(52, 54),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
