import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../logic/contact_card_controller.dart';
import '../../models/liked_musician.dart';
import 'contact_card_actions.dart';
import 'contact_card_header.dart';

class ContactCard extends StatefulWidget {
  const ContactCard({super.key, required this.musician});

  final LikedMusician musician;

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  final ContactCardController _controller = ContactCardController();
  bool _isContacting = false;

  Future<void> _contact() async {
    setState(() => _isContacting = true);
    try {
      final threadId = await _controller.ensureThreadId(widget.musician);
      if (!mounted) return;
      context.push(AppRoutes.messagesThreadPath(threadId));
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

  void _viewProfile() {
    final entity = _controller.toMusicianEntity(widget.musician);
    context.push(
      AppRoutes.musicianDetailPath(
        musicianId: entity.id,
        musicianName: entity.name,
      ),
      extra: entity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: colorScheme.surface,
      child: InkWell(
        onTap: _viewProfile,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ContactCardHeader(musician: widget.musician),
              const SizedBox(height: 16),
              ContactCardActions(
                onViewProfile: _viewProfile,
                onContact: _contact,
                isContacting: _isContacting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
