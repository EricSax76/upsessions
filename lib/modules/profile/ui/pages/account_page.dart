import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../auth/cubits/auth_cubit.dart';
import '../../../auth/domain/user_entity.dart';
import '../../../../home/ui/widgets/profile/profile_link_box.dart';
import '../widgets/account/account_photo_flow.dart';
import '../../account/account_missing_profile_view.dart';
import '../../account/account_photo_options_sheet.dart';
import '../../account/account_profile_details_card.dart';
import '../../account/account_profile_header_card.dart';
import '../../account/account_settings_card.dart';
import '../../../../core/widgets/responsive_constants.dart';
import '../../../auth/domain/profile_entity.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AccountPhotoFlow _photoFlow = AccountPhotoFlow();
  bool _twoFactor = false;
  bool _newsletter = true;

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final file = await _photoFlow.pickProfilePhoto(source);
      if (file == null) {
        return;
      }
      final bytes = await file.readAsBytes();
      final extension = AccountPhotoFlow.extensionFromName(file.name);
      if (!mounted) return;
      await context.read<ProfileCubit>().updateProfilePhoto(
        bytes,
        fileExtension: extension,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Foto actualizada')));
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la foto: $error')),
      );
    }
  }

  Future<void> _openPhotoOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => const AccountPhotoOptionsSheet(),
    );
    if (!mounted || source == null) return;
    await _pickAndUploadPhoto(source);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          final authState = context.watch<AuthCubit>().state;
          final user = authState.user;
          final profile = profileState.profile;

          if (profile == null || user == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Mi cuenta')),
              body: AccountMissingProfileView(
                isLoading: profileState.status == ProfileStatus.loading,
                error: profileState.errorMessage,
                onRetry: () => context.read<ProfileCubit>().refreshProfile(),
                onSignOut: () => context.read<AuthCubit>().signOut(),
              ),
            );
          }

          final uploadingPhoto = profileState.status == ProfileStatus.loading;
          final avatarUrl = profile.photoUrl ?? user.photoUrl;

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: isDesktop
                          ? _buildDesktopLayout(
                              profile: profile,
                              user: user,
                              avatarUrl: avatarUrl,
                              uploadingPhoto: uploadingPhoto,
                            )
                          : _buildMobileLayout(
                              profile: profile,
                              user: user,
                              avatarUrl: avatarUrl,
                              uploadingPhoto: uploadingPhoto,
                            ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout({
    required ProfileEntity profile,
    required UserEntity user,
    required String? avatarUrl,
    required bool uploadingPhoto,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar Content
        SizedBox(
          width: 320,
          child: Column(
            children: [
              AccountProfileHeaderCard(
                avatarUrl: avatarUrl,
                name: profile.name,
                email: user.email,
                uploadingPhoto: uploadingPhoto,
                onChangePhoto: _openPhotoOptions,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push(AppRoutes.profileEdit),
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
              // Logout button simplified or moved here
              Card(
                elevation: 0,
                // ignore: deprecated_member_use
                color: Theme.of(
                  context,
                  // ignore: deprecated_member_use
                ).colorScheme.errorContainer.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    // ignore: deprecated_member_use
                    color: Theme.of(context).colorScheme.error.withOpacity(0.2),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => context.read<AuthCubit>().signOut(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        // Main Content
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
              Text(
                'Preferencias de la cuenta',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              AccountSettingsCard(
                twoFactor: _twoFactor,
                newsletter: _newsletter,
                onTwoFactorChanged: (value) =>
                    setState(() => _twoFactor = value),
                onNewsletterChanged: (value) =>
                    setState(() => _newsletter = value),
                onSignOut: () => context.read<AuthCubit>().signOut(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout({
    required ProfileEntity profile,
    required UserEntity user,
    required String? avatarUrl,
    required bool uploadingPhoto,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccountProfileHeaderCard(
          avatarUrl: avatarUrl,
          name: profile.name,
          email: user.email,
          uploadingPhoto: uploadingPhoto,
          onChangePhoto: _openPhotoOptions,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => context.push(AppRoutes.profileEdit),
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
        AccountSettingsCard(
          twoFactor: _twoFactor,
          newsletter: _newsletter,
          onTwoFactorChanged: (value) => setState(() => _twoFactor = value),
          onNewsletterChanged: (value) => setState(() => _newsletter = value),
          onSignOut: () => context.read<AuthCubit>().signOut(),
        ),
      ],
    );
  }
}
