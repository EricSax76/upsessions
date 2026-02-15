import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/contacts/ui/widgets/musician_like_button.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/modules/groups/repositories/groups_repository.dart';

import '../../models/musician_entity.dart';
import '../../cubits/musician_detail_cubit.dart';
import '../../models/musician_liked_musician_mapper.dart';
import '../dialogs/invite_to_group_dialog.dart';
import '../widgets/musicians/musician_contact_card.dart';
import '../widgets/musicians/musician_highlights_grid.dart';
import '../widgets/musicians/musician_profile_header.dart';
import '../widgets/musicians/musician_styles_section.dart';

class MusicianDetailPage extends StatefulWidget {
  const MusicianDetailPage({super.key, required this.musician});

  final MusicianEntity musician;

  @override
  State<MusicianDetailPage> createState() => _MusicianDetailPageState();
}

class _MusicianDetailPageState extends State<MusicianDetailPage> {
  Future<void> _inviteMusician(BuildContext context) async {
    final cubit = context.read<MusicianDetailCubit>();
    final musician = widget.musician;
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
    final musician = widget.musician;

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
              SnackBar(content: Text('No se pudo iniciar el chat: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          final isContacting = state is MusicianDetailContacting;
          
          return LayoutBuilder(
            builder: (context, constraints) {
              // Responsive padding: larger on desktop
              final double horizontalPadding = constraints.maxWidth < 600 ? 20 : 32;
              final double topPadding = constraints.maxWidth < 600 ? 20 : 40;

              return SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
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
                          MusicianHighlightsGrid(musician: musician),
                          const SizedBox(height: 32),
                          MusicianStylesSection(styles: musician.styles),
                          const SizedBox(height: 32),
                          MusicianContactCard(
                            isLoading: isContacting,
                            onPressed: isContacting
                                ? null
                                : () => context
                                    .read<MusicianDetailCubit>()
                                    .contactMusician(musician),
                            onInvite: () => _inviteMusician(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
