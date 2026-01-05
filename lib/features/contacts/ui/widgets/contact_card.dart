import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../messaging/ui/pages/messages_page.dart';
import '../../controllers/contact_card_controller.dart';
import '../../models/liked_musician.dart';
import 'musician_like_button.dart';

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
      context.push(
        AppRoutes.messages,
        extra: MessagesPageArgs(initialThreadId: threadId),
      );
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
    context.push(AppRoutes.musicianDetail, extra: entity);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final musician = widget.musician;
    final styles = musician.nonEmptyStyles;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: (musician.photoUrl?.isNotEmpty ?? false)
                      ? NetworkImage(musician.photoUrl!)
                      : null,
                  child: (musician.photoUrl?.isNotEmpty ?? false)
                      ? null
                      : Text(musician.initials),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        musician.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${musician.instrument} · ${musician.city}'),
                      if (styles.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: styles
                              .map(
                                (style) => Chip(
                                  label: Text(style),
                                  backgroundColor: colorScheme.primary
                                      .withValues(alpha: 0.08),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                MusicianLikeButton(
                  musician: musician,
                  iconSize: 24,
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _isContacting ? null : _contact,
                  icon: _isContacting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.message_rounded),
                  label: Text(_isContacting ? 'Abriendo chat...' : 'Contactar'),
                ),
                OutlinedButton.icon(
                  onPressed: _viewProfile,
                  icon: const Icon(Icons.person),
                  label: const Text('Ver perfil'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
