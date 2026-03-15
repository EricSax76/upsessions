import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/home/ui/widgets/profile/profile_link_box.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/contacts/ui/widgets/musician_like_button.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';
import 'package:upsessions/modules/musicians/repositories/artist_image_repository.dart';
import 'package:upsessions/modules/musicians/repositories/musicians_repository.dart';
import 'package:upsessions/modules/profile/ui/widgets/account/account_profile_details_card.dart';

import '../../cubits/musician_detail_cubit.dart';
import '../../models/musician_entity.dart';
import '../../models/musician_liked_musician_mapper.dart';
import '../dialogs/invite_to_group_dialog.dart';
import '../widgets/musicians/musician_contact_card.dart';
import '../widgets/musicians/musician_profile_header.dart';

class MusicianDetailPage extends StatelessWidget {
  const MusicianDetailPage({super.key, required this.musician});

  final MusicianEntity musician;

  Future<void> _inviteMusician(
    BuildContext context,
    MusicianDetailState state,
  ) async {
    final musician = state.musician;
    if (musician == null) {
      return;
    }
    if (state.isOwnProfile) {
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

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.select(
      (AuthCubit cubit) => cubit.state.user?.id,
    );

    return BlocProvider(
      create: (context) => MusicianDetailCubit(
        chatRepository: locate<ChatRepository>(),
        groupsRepository: locate<GroupsRepository>(),
        musiciansRepository: locate<MusiciansRepository>(),
        artistImageRepository: locate<ArtistImageRepository>(),
      )..loadMusician(musician, currentUserId: currentUserId),
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.user?.id != current.user?.id,
        listener: (context, authState) {
          context.read<MusicianDetailCubit>().updateCurrentUser(
            authState.user?.id,
          );
        },
        child: BlocConsumer<MusicianDetailCubit, MusicianDetailState>(
          listenWhen: (previous, current) =>
              previous.navigateToThreadId != current.navigateToThreadId ||
              previous.contactErrorMessage != current.contactErrorMessage,
          listener: (context, state) {
            final threadId = state.navigateToThreadId;
            if (threadId != null && threadId.isNotEmpty) {
              context.read<MusicianDetailCubit>().consumeNavigation();
              context.push(AppRoutes.messagesThreadPath(threadId));
              return;
            }

            final contactError = state.contactErrorMessage;
            if (contactError != null && contactError.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No se pudo iniciar el chat: $contactError'),
                ),
              );
              context.read<MusicianDetailCubit>().clearContactError();
            }
          },
          builder: (context, state) {
            final resolvedMusician = state.musician ?? musician;
            if (state.isLoading && state.musician == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth < 600
                    ? 20.0
                    : 32.0;
                final topPadding = constraints.maxWidth < 600 ? 20.0 : 40.0;

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
                            const SizedBox.shrink(),
                            MusicianLikeButton(
                              musician: resolvedMusician.toLikedMusician(),
                              iconSize: 28,
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        MusicianProfileHeader(musician: resolvedMusician),
                        const SizedBox(height: 32),
                        if (state.loadErrorMessage != null) ...[
                          Text(
                            state.loadErrorMessage!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (state.areAffinityArtistsLoading) ...[
                          const LinearProgressIndicator(minHeight: 2),
                          const SizedBox(height: 12),
                        ],
                        AccountProfileDetailsCard(
                          bio: resolvedMusician.bio,
                          location: resolvedMusician.city,
                          skills: resolvedMusician.styles,
                          influences: resolvedMusician.influences,
                          spotifyArtistImagesFuture:
                              resolvedMusician.influences.isEmpty
                              ? null
                              : Future.value(state.spotifyAffinityByArtist),
                        ),
                        const SizedBox(height: 24),
                        ProfileLinkBox(
                          links: resolvedMusician.links,
                          readOnly: true,
                        ),
                        if (!state.isOwnProfile) ...[
                          const SizedBox(height: 32),
                          MusicianContactCard(
                            isLoading: state.isContacting,
                            onPressed: state.isContacting
                                ? null
                                : () => context
                                      .read<MusicianDetailCubit>()
                                      .contactCurrentMusician(),
                            onInvite: () => _inviteMusician(context, state),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
