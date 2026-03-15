import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import 'package:upsessions/modules/musicians/models/musician_string_utils.dart';
import 'package:upsessions/modules/musicians/ui/widgets/artist_image_label.dart';
import 'package:upsessions/modules/profile/cubit/profile_form_cubit.dart';
import 'profile_affinity_input.dart';

class ProfileAffinitySection extends StatelessWidget {
  const ProfileAffinitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.profileAffinityTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          loc.profileAffinityDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        const ProfileAffinityInput(),
        const SizedBox(height: 16),
        BlocBuilder<ProfileFormCubit, ProfileFormState>(
          builder: (context, state) {
            if (state.influences.isEmpty) {
              return Text(
                loc.profileAffinityEmpty,
                style: Theme.of(context).textTheme.bodyMedium,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildInfluenceList(context, state),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _buildInfluenceList(
    BuildContext context,
    ProfileFormState state,
  ) {
    final cubit = context.read<ProfileFormCubit>();
    final isMobile = MediaQuery.sizeOf(context).width < 640;
    final entries = state.influences.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    return entries.map((entry) {
      final style = entry.key;
      final artists = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              style,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (isMobile)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: artists.map((artist) {
                  final info =
                      state.artistImagesByName[normalizeArtistName(artist)];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ArtistChipWithAttribution(
                      spotifyUrl: info?.spotifyUrl,
                      expand: true,
                      alignStart: true,
                      chip: Chip(
                        label: ArtistImageLabel(
                          artist: artist,
                          imageUrl: info?.imageUrl,
                          thumbnailSize: 34,
                          labelMaxWidth: 240,
                        ),
                        onDeleted: () => cubit.removeInfluence(style, artist),
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: artists.map((artist) {
                  final info =
                      state.artistImagesByName[normalizeArtistName(artist)];
                  return ArtistChipWithAttribution(
                    spotifyUrl: info?.spotifyUrl,
                    chip: Chip(
                      label: ArtistImageLabel(
                        artist: artist,
                        imageUrl: info?.imageUrl,
                        thumbnailSize: 34,
                        labelMaxWidth: 240,
                      ),
                      onDeleted: () => cubit.removeInfluence(style, artist),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      );
    }).toList();
  }
}
