import 'package:flutter/material.dart';

import '../../../models/event_entity.dart';
import 'event_action_widgets.dart';
import 'event_content_sections.dart';
import 'event_detail_banner.dart';
import 'event_detail_helpers.dart';
import 'event_header_card.dart';

class EventDetailList extends StatelessWidget {
  const EventDetailList({
    super.key,
    required this.event,
    required this.meta,
    required this.isUploadingBanner,
    required this.onUploadBanner,
    required this.onCopyTemplate,
    required this.onShare,
    required this.horizontalPadding,
  });

  final EventEntity event;
  final EventDetailMeta meta;
  final bool isUploadingBanner;
  final VoidCallback onUploadBanner;
  final Future<void> Function() onCopyTemplate;
  final VoidCallback onShare;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 24),
      children: [
        EventBanner(
          imageUrl: event.bannerImageUrl,
          isUploading: isUploadingBanner,
          onUpload: onUploadBanner,
          eventTitle: event.title,
        ),
        if (event.bannerImageUrl != null) const SizedBox(height: 16),
        EventHeaderCard(event: event, meta: meta),
        const SizedBox(height: 16),
        EventDescriptionSection(event: event),
        const SizedBox(height: 12),
        EventContactSection(event: event),
        const SizedBox(height: 12),
        EventLineupSection(event: event),
        const SizedBox(height: 12),
        EventTagsSection(event: event),
        const SizedBox(height: 12),
        EventResourcesSection(event: event),
        if (event.notes?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          EventNotesSection(notes: event.notes!),
        ],
        const SizedBox(height: 16),
        EventQuickActionsSection(onCopyTemplate: onCopyTemplate),
        const SizedBox(height: 12),
        EventActionButtons(onShare: onShare, onCopyTemplate: onCopyTemplate),
      ],
    );
  }
}
