import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/locator/locator.dart';
import '../../../../home/ui/pages/user_shell_page.dart';
import '../../../../modules/musicians/models/musician_entity.dart';
import '../../../messaging/data/chat_repository.dart';
import '../../../messaging/presentation/pages/messages_page.dart';
import '../../application/liked_musicians_controller.dart';
import '../../domain/liked_musician.dart';
import '../widgets/musician_like_button.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = locate<LikedMusiciansController>();
    return UserShellPage(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final contacts = controller.contacts;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ContactsHeader(total: contacts.length),
                  const SizedBox(height: 24),
                  if (contacts.isEmpty)
                    const _EmptyContacts()
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: contacts.length,
                        separatorBuilder: (_, unused) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          return _ContactCard(musician: contact);
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ContactsHeader extends StatelessWidget {
  const _ContactsHeader({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contactos',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          total == 1
              ? 'Tienes 1 músico guardado.'
              : 'Tienes $total músicos guardados.',
        ),
      ],
    );
  }
}

class _EmptyContacts extends StatelessWidget {
  const _EmptyContacts();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 72, color: colorScheme.primary),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes contactos.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explora músicos y toca el corazón para guardarlos aquí.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatefulWidget {
  const _ContactCard({required this.musician});

  final LikedMusician musician;

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  final ChatRepository _chatRepository = locate();
  bool _isContacting = false;

  Future<void> _contact() async {
    setState(() => _isContacting = true);
    try {
      final participantId = widget.musician.ownerId.isNotEmpty
          ? widget.musician.ownerId
          : widget.musician.id;
      final thread = await _chatRepository.ensureThreadWithParticipant(
        participantId: participantId,
        participantName: widget.musician.name,
      );
      if (!mounted) {
        return;
      }
      context.push(
        AppRoutes.messages,
        extra: MessagesPageArgs(initialThreadId: thread.id),
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
    final musician = widget.musician;
    final entity = MusicianEntity(
      id: musician.id,
      ownerId: musician.ownerId,
      name: musician.name,
      instrument: musician.instrument,
      city: musician.city,
      styles: musician.nonEmptyStyles,
      experienceYears: musician.experienceYears,
      photoUrl: musician.photoUrl,
    );
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
