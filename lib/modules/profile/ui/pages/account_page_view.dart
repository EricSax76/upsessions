import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upsessions/modules/profile/cubit/account_settings_cubit.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../auth/cubits/auth_cubit.dart';
import '../../models/account_missing_profile_view.dart';
import '../widgets/account/account_page_layout.dart';
import '../widgets/account/account_photo_flow.dart';
import '../dialogs/account_photo_options_sheet.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';

class AccountPageView extends StatelessWidget {
  const AccountPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountSettingsCubit(),
      child: const _AccountPageViewContent(),
    );
  }
}

class _AccountPageViewContent extends StatefulWidget {
  const _AccountPageViewContent();

  @override
  State<_AccountPageViewContent> createState() => _AccountPageViewContentState();
}

class _AccountPageViewContentState extends State<_AccountPageViewContent> {
  final AccountPhotoFlow _photoFlow = AccountPhotoFlow();

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
                  child: AccountMissingProfileView(
                    isLoading: profileState.status == ProfileStatus.loading,
                    error: profileState.errorMessage,
                    onRetry:
                        () => context.read<ProfileCubit>().refreshProfile(),
                    onSignOut: () => context.read<AuthCubit>().signOut(),
                  ),
                ),
              ],
            );
          }

          final uploadingPhoto = profileState.status == ProfileStatus.loading;
          final avatarUrl = profile.photoUrl ?? user.photoUrl;

          return BlocBuilder<AccountSettingsCubit, AccountSettingsState>(
             builder: (context, settingsState) {
                return AccountPageLayout(
                  profile: profile,
                  user: user,
                  avatarUrl: avatarUrl,
                  uploadingPhoto: uploadingPhoto,
                  onChangePhoto: _openPhotoOptions,
                  onEditProfile: () => context.push(AppRoutes.profileEdit),
                  onSignOut: () => context.read<AuthCubit>().signOut(),
                  twoFactor: settingsState.twoFactorEnabled,
                  newsletter: settingsState.newsletterEnabled,
                  onTwoFactorChanged: (value) =>
                      context.read<AccountSettingsCubit>().toggleTwoFactor(value),
                  onNewsletterChanged: (value) =>
                      context.read<AccountSettingsCubit>().toggleNewsletter(value),
                );
             },
          );
        },
      ),
    );
  }
}
