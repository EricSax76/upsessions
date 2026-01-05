import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../auth/cubits/auth_cubit.dart';
import '../../../../home/ui/widgets/profile/profile_link_box.dart';
import '../widgets/account/account_photo_flow.dart';
import '../../account/account_missing_profile_view.dart';
import '../../account/account_photo_options_sheet.dart';
import '../../account/account_profile_details_card.dart';
import '../../account/account_profile_header_card.dart';
import '../../account/account_settings_card.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AccountPhotoFlow _photoFlow = AccountPhotoFlow();
  bool _twoFactor = false;
  bool _newsletter = true;
  bool _uploadingPhoto = false;
  bool _profileRequested = false;
  String? _lastUserId;

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final file = await _photoFlow.pickProfilePhoto(source);
      if (file == null) {
        return;
      }
      setState(() => _uploadingPhoto = true);
      final bytes = await file.readAsBytes();
      final extension = AccountPhotoFlow.extensionFromName(file.name);
      if (!mounted) return;
      final authCubit = context.read<AuthCubit>();
      await authCubit.updateProfilePhoto(bytes, fileExtension: extension);
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
    } finally {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
      }
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
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.user != current.user ||
          previous.profile != current.profile ||
          previous.isLoading != current.isLoading ||
          previous.lastAction != current.lastAction,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go(AppRoutes.login);
          return;
        }

        final user = state.user;
        final profile = state.profile;
        if (user?.id != _lastUserId) {
          _lastUserId = user?.id;
          _profileRequested = false;
        }
        final isLoadingProfile =
            state.isLoading && state.lastAction == AuthAction.loadProfile;
        if (!_profileRequested &&
            user != null &&
            profile == null &&
            !isLoadingProfile) {
          _profileRequested = true;
          context.read<AuthCubit>().refreshProfile();
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        final user = state.user;
        final isLoadingProfile =
            state.isLoading && state.lastAction == AuthAction.loadProfile;
        final loadError = state.lastAction == AuthAction.loadProfile
            ? state.errorMessage
            : null;
        if (profile == null || user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mi cuenta')),
            body: AccountMissingProfileView(
              isLoading: isLoadingProfile,
              error: loadError,
              onRetry: () {
                _profileRequested = false;
                context.read<AuthCubit>().refreshProfile();
              },
              onSignOut: () => context.read<AuthCubit>().signOut(),
            ),
          );
        }
        final avatarUrl = profile.photoUrl ?? user.photoUrl;
        return Scaffold(
          appBar: AppBar(title: const Text('Mi cuenta')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AccountProfileHeaderCard(
                  avatarUrl: avatarUrl,
                  name: profile.name,
                  email: user.email,
                  uploadingPhoto: _uploadingPhoto,
                  onChangePhoto: _openPhotoOptions,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.profileEdit),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Actualizar perfil'),
                  ),
                ),
                const SizedBox(height: 16),
                const ProfileLinkBox(),
                const SizedBox(height: 16),
                AccountProfileDetailsCard(
                  bio: profile.bio,
                  location: profile.location,
                  skills: profile.skills,
                  links: profile.links,
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
        );
      },
    );
  }
}
