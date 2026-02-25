import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/modules/musicians/models/artist_image_info.dart';
import 'package:upsessions/modules/musicians/repositories/artist_image_repository.dart';

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
    return const _AccountPageViewContent();
  }
}

class _AccountPageViewContent extends StatefulWidget {
  const _AccountPageViewContent();

  @override
  State<_AccountPageViewContent> createState() =>
      _AccountPageViewContentState();
}

class _AccountPageViewContentState extends State<_AccountPageViewContent> {
  final AccountPhotoFlow _photoFlow = AccountPhotoFlow();
  late final ArtistImageRepository _artistImageRepository;
  String _spotifyAffinityCacheKey = '';
  Future<Map<String, ArtistImageInfo>>? _spotifyAffinityFuture;

  @override
  void initState() {
    super.initState();
    _artistImageRepository = locate<ArtistImageRepository>();
  }

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

  List<String> _flattenUniqueAffinityArtists(
    Map<String, List<String>> influences,
  ) {
    final uniqueByKey = <String, String>{};
    final sortedStyles = influences.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    for (final style in sortedStyles) {
      final artists = influences[style] ?? const <String>[];
      for (final rawArtist in artists) {
        final artist = rawArtist.trim();
        if (artist.isEmpty) {
          continue;
        }
        final key = normalizeArtistName(artist);
        if (key.isEmpty) {
          continue;
        }
        uniqueByKey.putIfAbsent(key, () => artist);
      }
    }

    return uniqueByKey.values.toList(growable: false);
  }

  Future<Map<String, ArtistImageInfo>>? _spotifyAffinityFutureFor(
    Map<String, List<String>> influences,
  ) {
    if (influences.isEmpty) {
      return null;
    }

    final artists = _flattenUniqueAffinityArtists(influences);
    if (artists.isEmpty) {
      return null;
    }

    final cacheKey =
        artists
            .map(normalizeArtistName)
            .where((key) => key.isNotEmpty)
            .toList(growable: false)
          ..sort();
    final joinedKey = cacheKey.join('|');

    if (_spotifyAffinityFuture != null &&
        joinedKey == _spotifyAffinityCacheKey) {
      return _spotifyAffinityFuture;
    }

    _spotifyAffinityCacheKey = joinedKey;
    _spotifyAffinityFuture = _artistImageRepository.resolveArtists(artists);
    return _spotifyAffinityFuture;
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
                    onRetry: () =>
                        context.read<ProfileCubit>().refreshProfile(),
                    onSignOut: () => context.read<AuthCubit>().signOut(),
                  ),
                ),
              ],
            );
          }

          final uploadingPhoto = profileState.status == ProfileStatus.loading;
          final avatarUrl = profile.photoUrl ?? user.photoUrl;
          final spotifyAffinityFuture = _spotifyAffinityFutureFor(
            profile.influences,
          );

          return AccountPageLayout(
            profile: profile,
            user: user,
            avatarUrl: avatarUrl,
            uploadingPhoto: uploadingPhoto,
            spotifyArtistImagesFuture: spotifyAffinityFuture,
            onChangePhoto: _openPhotoOptions,
            onEditProfile: () => context.push(AppRoutes.profileEdit),
            onAddLink: (title, url) {
              final newLinks = Map<String, String>.from(profile.links);
              newLinks[title] = url;
              context.read<ProfileCubit>().updateProfile(
                profile.copyWith(links: newLinks),
              );
            },
            onRemoveLink: (key) {
              final newLinks = Map<String, String>.from(profile.links);
              newLinks.remove(key);
              context.read<ProfileCubit>().updateProfile(
                profile.copyWith(links: newLinks),
              );
            },
          );
        },
      ),
    );
  }
}
