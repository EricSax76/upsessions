import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/constants/app_spacing.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';

import '../../models/announcement_entity.dart';
import '../widgets/announcement_detail/announcement_contact_card.dart';
import '../widgets/announcement_detail/announcement_description_card.dart';
import '../widgets/announcement_detail/announcement_header_card.dart';
import '../widgets/announcement_detail/announcement_image_card.dart';
import '../widgets/announcement_detail/announcement_styles_card.dart';

class AnnouncementDetailPage extends StatefulWidget {
  const AnnouncementDetailPage({super.key, required this.announcement});

  final AnnouncementEntity announcement;

  @override
  State<AnnouncementDetailPage> createState() => _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
  final ChatRepository _chatRepository = locate();
  bool _isContacting = false;

  Future<void> _contactAuthor() async {
    setState(() => _isContacting = true);
    try {
      final thread = await _chatRepository.ensureThreadWithParticipant(
        participantId: widget.announcement.authorId,
        participantName: widget.announcement.author,
      );
      if (!mounted) return;
      context.push(AppRoutes.messagesThreadPath(thread.id));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar el chat: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isContacting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcement = widget.announcement;
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
                    AnnouncementContactCard(
                      author: announcement.author,
                      isLoading: _isContacting,
                      onContact: _isContacting ? null : _contactAuthor,
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
