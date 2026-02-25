import 'package:flutter/material.dart';

import '../../../../../core/widgets/constants/breakpoints.dart';
import '../../../../../features/home/ui/widgets/profile/profile_link_box.dart';
import '../../../../auth/models/profile_entity.dart';
import '../../../../auth/models/user_entity.dart';
import '../../../../musicians/models/artist_image_info.dart';
import 'account_profile_details_card.dart';
import 'account_profile_header_card.dart';

class AccountPageLayout extends StatelessWidget {
  const AccountPageLayout({
    super.key,
    required this.profile,
    required this.user,
    required this.avatarUrl,
    required this.uploadingPhoto,
    this.spotifyArtistImagesFuture,
    required this.onChangePhoto,
    required this.onEditProfile,
    required this.onAddLink,
    required this.onRemoveLink,
  });

  final ProfileEntity profile;
  final UserEntity user;
  final String? avatarUrl;
  final bool uploadingPhoto;
  final Future<Map<String, ArtistImageInfo>>? spotifyArtistImagesFuture;
  final VoidCallback onChangePhoto;
  final VoidCallback onEditProfile;
  final void Function(String title, String url) onAddLink;
  final void Function(String key) onRemoveLink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            'Mi cuenta',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > Breakpoints.desktop;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: isDesktop
                    ? AccountDesktopLayout(
                        profile: profile,
                        user: user,
                        avatarUrl: avatarUrl,
                        uploadingPhoto: uploadingPhoto,
                        spotifyArtistImagesFuture: spotifyArtistImagesFuture,
                        onChangePhoto: onChangePhoto,
                        onEditProfile: onEditProfile,
                        onAddLink: onAddLink,
                        onRemoveLink: onRemoveLink,
                      )
                    : AccountMobileLayout(
                        profile: profile,
                        user: user,
                        avatarUrl: avatarUrl,
                        uploadingPhoto: uploadingPhoto,
                        spotifyArtistImagesFuture: spotifyArtistImagesFuture,
                        onChangePhoto: onChangePhoto,
                        onEditProfile: onEditProfile,
                        onAddLink: onAddLink,
                        onRemoveLink: onRemoveLink,
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AccountDesktopLayout extends StatelessWidget {
  const AccountDesktopLayout({
    super.key,
    required this.profile,
    required this.user,
    required this.avatarUrl,
    required this.uploadingPhoto,
    this.spotifyArtistImagesFuture,
    required this.onChangePhoto,
    required this.onEditProfile,
    required this.onAddLink,
    required this.onRemoveLink,
  });

  final ProfileEntity profile;
  final UserEntity user;
  final String? avatarUrl;
  final bool uploadingPhoto;
  final Future<Map<String, ArtistImageInfo>>? spotifyArtistImagesFuture;
  final VoidCallback onChangePhoto;
  final VoidCallback onEditProfile;
  final void Function(String title, String url) onAddLink;
  final void Function(String key) onRemoveLink;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 320,
          child: Column(
            children: [
              AccountProfileHeaderCard(
                avatarUrl: avatarUrl,
                name: profile.name,
                email: user.email,
                uploadingPhoto: uploadingPhoto,
                onChangePhoto: onChangePhoto,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onEditProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Actualizar perfil'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ProfileLinkBox(
                links: profile.links,
                onAddLink: onAddLink,
                onRemoveLink: onRemoveLink,
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccountProfileDetailsCard(
                bio: profile.bio,
                location: profile.location,
                skills: profile.skills,
                influences: profile.influences,
                spotifyArtistImagesFuture: spotifyArtistImagesFuture,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AccountMobileLayout extends StatelessWidget {
  const AccountMobileLayout({
    super.key,
    required this.profile,
    required this.user,
    required this.avatarUrl,
    required this.uploadingPhoto,
    this.spotifyArtistImagesFuture,
    required this.onChangePhoto,
    required this.onEditProfile,
    required this.onAddLink,
    required this.onRemoveLink,
  });

  final ProfileEntity profile;
  final UserEntity user;
  final String? avatarUrl;
  final bool uploadingPhoto;
  final Future<Map<String, ArtistImageInfo>>? spotifyArtistImagesFuture;
  final VoidCallback onChangePhoto;
  final VoidCallback onEditProfile;
  final void Function(String title, String url) onAddLink;
  final void Function(String key) onRemoveLink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccountProfileHeaderCard(
          avatarUrl: avatarUrl,
          name: profile.name,
          email: user.email,
          uploadingPhoto: uploadingPhoto,
          onChangePhoto: onChangePhoto,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onEditProfile,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Actualizar perfil'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 24),
        ProfileLinkBox(
          links: profile.links,
          onAddLink: onAddLink,
          onRemoveLink: onRemoveLink,
        ),
        const SizedBox(height: 24),
        AccountProfileDetailsCard(
          bio: profile.bio,
          location: profile.location,
          skills: profile.skills,
          influences: profile.influences,
          spotifyArtistImagesFuture: spotifyArtistImagesFuture,
        ),
      ],
    );
  }
}
