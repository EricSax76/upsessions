import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/sm_avatar.dart';
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
    final musician = widget.musician;
    final styles = musician.nonEmptyStyles;

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmAvatar(
                    radius: 24,
                    imageUrl: musician.photoUrl,
                    initials: musician.initials,
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                musician.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            MusicianLikeButton(
                              musician: musician,
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${musician.instrument} · ${musician.city}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (styles.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            styles.take(3).join(" · "),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _viewProfile,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                      ),
                      child: const Text('Ver perfil'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _isContacting ? null : _contact,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: _isContacting
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                      label: Text(
                        _isContacting ? '...' : 'Contactar',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
