import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/features/contacts/ui/widgets/musician_like_button.dart';
import 'package:upsessions/features/messaging/ui/pages/messages_page.dart';

import '../../models/musician_entity.dart';
import '../../controllers/musician_detail_controller.dart';
import '../../models/musician_liked_musician_mapper.dart';
import '../widgets/invite/invite_to_group_dialog.dart';
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
  final MusicianDetailController _controller = MusicianDetailController();
  bool _isContacting = false;

  Future<void> _contactMusician() async {
    setState(() => _isContacting = true);
    try {
      final threadId = await _controller.ensureThreadId(widget.musician);
      if (!mounted) return;
      context.push(
        AppRoutes.messages,
        extra: MessagesPageArgs(initialThreadId: threadId),
      );
    } catch (error) {
      debugPrint('Error contacting musician: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar el chat: $error')),
      );
    } finally {
      if (mounted) setState(() => _isContacting = false);
    }
  }

  Future<void> _inviteMusician() async {
    final musician = widget.musician;
    final targetUid = _controller.participantIdFor(musician);
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
        groupsRepository: _controller.groupsRepository,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final musician = widget.musician;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive padding: larger on desktop
        final double horizontalPadding = constraints.maxWidth < 600 ? 20 : 32;
        final double topPadding = constraints.maxWidth < 600 ? 20 : 40;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: SingleChildScrollView(
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
                    isLoading: _isContacting,
                    onPressed: _isContacting ? null : _contactMusician,
                    onInvite: _inviteMusician,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
