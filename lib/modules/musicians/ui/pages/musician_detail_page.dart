import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/home/ui/widgets/profile/profile_link_box.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/contacts/ui/widgets/musician_like_button.dart';
import 'package:upsessions/modules/messaging/repositories/chat_repository.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/musicians/models/artist_image_info.dart';
import 'package:upsessions/modules/musicians/repositories/artist_image_repository.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/modules/profile/ui/widgets/account/account_profile_details_card.dart';

import '../../models/musician_entity.dart';
import '../../cubits/musician_detail_cubit.dart';
import '../../models/musician_liked_musician_mapper.dart';
import '../dialogs/invite_to_group_dialog.dart';
import '../widgets/musicians/musician_contact_card.dart';
import '../widgets/musicians/musician_profile_header.dart';

class MusicianDetailPage extends StatefulWidget {
  const MusicianDetailPage({super.key, required this.musician});

  final MusicianEntity musician;

  @override
  State<MusicianDetailPage> createState() => _MusicianDetailPageState();
}

class _MusicianDetailPageState extends State<MusicianDetailPage> {
  late final Future<MusicianEntity?> _musicianFuture;
  late final ArtistImageRepository _artistImageRepository;
  String _spotifyAffinityCacheKey = '';
  Future<Map<String, ArtistImageInfo>>? _spotifyAffinityFuture;

  @override
  void initState() {
    super.initState();
    _musicianFuture = locate<MusiciansRepository>().findById(
      widget.musician.id,
    );
    _artistImageRepository = locate<ArtistImageRepository>();
  }

  Future<void> _inviteMusician(
    BuildContext context,
    MusicianEntity musician,
    String? currentUserId,
  ) async {
    if (_isOwnProfile(musician, currentUserId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes invitarte a ti mismo a un grupo.'),
        ),
      );
      return;
    }

    final cubit = context.read<MusicianDetailCubit>();
    final targetUid = cubit.getParticipantId(musician);

    if (targetUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este músico no tiene UID válido.')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => InviteToGroupDialog(
        target: musician,
        targetUid: targetUid,
        groupsRepository: cubit.groupsRepository,
      ),
    );
  }

  bool _isOwnProfile(MusicianEntity musician, String? currentUserId) {
    final currentId = currentUserId?.trim() ?? '';
    if (currentId.isEmpty) {
      return false;
    }
    final ownerId = musician.ownerId.trim();
    final musicianId = musician.id.trim();
    return ownerId == currentId || musicianId == currentId;
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

  Future<Map<String, ArtistImageInfo>> _spotifyAffinityFutureFor(
    Map<String, List<String>> influences,
  ) {
    final artists = _flattenUniqueAffinityArtists(influences);
    if (artists.isEmpty) {
      return Future.value(const <String, ArtistImageInfo>{});
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
      return _spotifyAffinityFuture!;
    }

    _spotifyAffinityCacheKey = joinedKey;
    _spotifyAffinityFuture = _artistImageRepository.resolveArtists(artists);
    return _spotifyAffinityFuture!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MusicianDetailCubit(
        chatRepository: locate<ChatRepository>(),
        groupsRepository: locate<GroupsRepository>(),
      ),
      child: BlocConsumer<MusicianDetailCubit, MusicianDetailState>(
        listener: (context, state) {
          if (state is MusicianDetailContactSuccess) {
            context.push(AppRoutes.messagesThreadPath(state.threadId));
          } else if (state is MusicianDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No se pudo iniciar el chat: ${state.message}'),
              ),
            );
          }
        },
        builder: (context, state) {
          final isContacting = state is MusicianDetailContacting;

          return FutureBuilder<MusicianEntity?>(
            future: _musicianFuture,
            builder: (context, snapshot) {
              final musician = snapshot.data ?? widget.musician;
              final currentUserId = context.select(
                (AuthCubit cubit) => cubit.state.user?.id,
              );
              final isOwnProfile = _isOwnProfile(musician, currentUserId);

              return LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive padding: larger on desktop
                  final double horizontalPadding = constraints.maxWidth < 600
                      ? 20
                      : 32;
                  final double topPadding = constraints.maxWidth < 600
                      ? 20
                      : 40;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        topPadding,
                        horizontalPadding,
                        80,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Breadcrumb or Back button could go here
                              const SizedBox.shrink(), // Placeholder if needed
                              MusicianLikeButton(
                                musician: musician.toLikedMusician(),
                                iconSize: 28,
                                padding: const EdgeInsets.all(4),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          MusicianProfileHeader(musician: musician),
                          const SizedBox(height: 32),
                          AccountProfileDetailsCard(
                            bio: musician.bio,
                            location: musician.city,
                            skills: musician.styles,
                            influences: musician.influences,
                            spotifyArtistImagesFuture:
                                musician.influences.isEmpty
                                ? null
                                : _spotifyAffinityFutureFor(
                                    musician.influences,
                                  ),
                          ),
                          const SizedBox(height: 24),
                          ProfileLinkBox(links: musician.links, readOnly: true),
                          if (!isOwnProfile) ...[
                            const SizedBox(height: 32),
                            MusicianContactCard(
                              isLoading: isContacting,
                              onPressed: isContacting
                                  ? null
                                  : () => context
                                        .read<MusicianDetailCubit>()
                                        .contactMusician(
                                          musician,
                                          currentUserId: currentUserId,
                                        ),
                              onInvite: () => _inviteMusician(
                                context,
                                musician,
                                currentUserId,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
