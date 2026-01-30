import 'package:flutter/material.dart';

import '../../../../../core/widgets/responsive_constants.dart';
import '../../../../../home/ui/widgets/profile/profile_link_box.dart';
import '../../../../auth/models/profile_entity.dart';
import '../../../../auth/models/user_entity.dart';
import 'account_logout_card.dart';
import 'account_preferences_section.dart';
import 'account_profile_details_card.dart';
import 'account_profile_header_card.dart';

class AccountPageLayout extends StatelessWidget {
  const AccountPageLayout({
    super.key,
    required this.profile,
    required this.user,
    required this.avatarUrl,
    required this.uploadingPhoto,
    required this.onChangePhoto,
    required this.onEditProfile,
    required this.onSignOut,
    required this.twoFactor,
    required this.newsletter,
    required this.onTwoFactorChanged,
    required this.onNewsletterChanged,
  });

  final ProfileEntity profile;
  final UserEntity user;
  final String? avatarUrl;
  final bool uploadingPhoto;
  final VoidCallback onChangePhoto;
  final VoidCallback onEditProfile;
  final VoidCallback onSignOut;
  final bool twoFactor;
  final bool newsletter;
  final ValueChanged<bool> onTwoFactorChanged;
  final ValueChanged<bool> onNewsletterChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi cuenta'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > kDesktopBreakpoint;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: isDesktop
                    ? AccountDesktopLayout(
                        profile: profile,
                        user: user,
                        avatarUrl: avatarUrl,
                        uploadingPhoto: uploadingPhoto,
                        onChangePhoto: onChangePhoto,
                        onEditProfile: onEditProfile,
                        onSignOut: onSignOut,
                        twoFactor: twoFactor,
                        newsletter: newsletter,
                        onTwoFactorChanged: onTwoFactorChanged,
                        onNewsletterChanged: onNewsletterChanged,
                      )
                    : AccountMobileLayout(
                        profile: profile,
                        user: user,
                        avatarUrl: avatarUrl,
                        uploadingPhoto: uploadingPhoto,
                        onChangePhoto: onChangePhoto,
                        onEditProfile: onEditProfile,
                        onSignOut: onSignOut,
                        twoFactor: twoFactor,
                        newsletter: newsletter,
                        onTwoFactorChanged: onTwoFactorChanged,
                        onNewsletterChanged: onNewsletterChanged,
                      ),
              ),
            ),
          );
        },
      ),
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
    required this.onChangePhoto,
    required this.onEditProfile,
    required this.onSignOut,
    required this.twoFactor,
    required this.newsletter,
    required this.onTwoFactorChanged,
    required this.onNewsletterChanged,
  });

  final ProfileEntity profile;
  final UserEntity user;
  final String? avatarUrl;
  final bool uploadingPhoto;
  final VoidCallback onChangePhoto;
  final VoidCallback onEditProfile;
  final VoidCallback onSignOut;
  final bool twoFactor;
  final bool newsletter;
  final ValueChanged<bool> onTwoFactorChanged;
  final ValueChanged<bool> onNewsletterChanged;

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
              const ProfileLinkBox(),
              const SizedBox(height: 16),
              AccountLogoutCard(onSignOut: onSignOut),
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
                links: profile.links,
              ),
              const SizedBox(height: 24),
              AccountPreferencesSection(
                showTitle: true,
                twoFactor: twoFactor,
                newsletter: newsletter,
                onTwoFactorChanged: onTwoFactorChanged,
                onNewsletterChanged: onNewsletterChanged,
                onSignOut: onSignOut,
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
    required this.onChangePhoto,
    required this.onEditProfile,
    required this.onSignOut,
    required this.twoFactor,
    required this.newsletter,
    required this.onTwoFactorChanged,
    required this.onNewsletterChanged,
  });

  final ProfileEntity profile;
  final UserEntity user;
  final String? avatarUrl;
  final bool uploadingPhoto;
  final VoidCallback onChangePhoto;
  final VoidCallback onEditProfile;
  final VoidCallback onSignOut;
  final bool twoFactor;
  final bool newsletter;
  final ValueChanged<bool> onTwoFactorChanged;
  final ValueChanged<bool> onNewsletterChanged;

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
        const ProfileLinkBox(),
        const SizedBox(height: 24),
        AccountProfileDetailsCard(
          bio: profile.bio,
          location: profile.location,
          skills: profile.skills,
          links: profile.links,
        ),
        const SizedBox(height: 24),
        AccountPreferencesSection(
          twoFactor: twoFactor,
          newsletter: newsletter,
          onTwoFactorChanged: onTwoFactorChanged,
          onNewsletterChanged: onNewsletterChanged,
          onSignOut: onSignOut,
        ),
      ],
    );
  }
}
