import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/constants/app_spacing.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/modules/announcements/cubits/announcement_detail_cubit.dart';

import '../../models/announcement_entity.dart';
import '../widgets/announcement_detail/announcement_contact_card.dart';
import '../widgets/announcement_detail/announcement_description_card.dart';
import '../widgets/announcement_detail/announcement_header_card.dart';
import '../widgets/announcement_detail/announcement_image_card.dart';
import '../widgets/announcement_detail/announcement_styles_card.dart';

class AnnouncementDetailPage extends StatelessWidget {
  const AnnouncementDetailPage({super.key, required this.announcement});

  final AnnouncementEntity announcement;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => AnnouncementDetailCubit(
            chatRepository: locate<ChatRepository>(),
          ),
      child: BlocListener<AnnouncementDetailCubit, AnnouncementDetailState>(
        listener: (context, state) {
          if (state.status == AnnouncementDetailStatus.success &&
              state.threadId != null) {
            context.push(AppRoutes.messagesThreadPath(state.threadId!));
          } else if (state.status == AnnouncementDetailStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'No se pudo iniciar el chat: ${state.errorMessage}',
                ),
              ),
            );
          }
        },
        child: _AnnouncementDetailContent(announcement: announcement),
      ),
    );
  }
}

class _AnnouncementDetailContent extends StatelessWidget {
  const _AnnouncementDetailContent({required this.announcement});

  final AnnouncementEntity announcement;

  @override
  Widget build(BuildContext context) {
    final imageUrl = announcement.imageUrl?.trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;
        final horizontalPadding = isCompact ? 20.0 : 32.0;
        final topPadding = isCompact ? 20.0 : 40.0;

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
                    if (imageUrl != null && imageUrl.isNotEmpty) ...[
                      AnnouncementImageCard(imageUrl: imageUrl),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    AnnouncementHeaderCard(announcement: announcement),
                    const SizedBox(height: AppSpacing.lg),
                    AnnouncementDescriptionCard(body: announcement.body),
                    if (announcement.styles.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      AnnouncementStylesCard(styles: announcement.styles),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    BlocBuilder<AnnouncementDetailCubit, AnnouncementDetailState>(
                      builder: (context, state) {
                        final isContacting =
                            state.status == AnnouncementDetailStatus.contacting;
                        return AnnouncementContactCard(
                          author: announcement.author,
                          isLoading: isContacting,
                          onContact:
                              isContacting
                                  ? null
                                  : () => context
                                      .read<AnnouncementDetailCubit>()
                                      .contactAuthor(
                                        authorId: announcement.authorId,
                                        authorName: announcement.author,
                                      ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
