import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/messaging/data/chat_repository.dart';
import 'package:upsessions/features/messaging/presentation/pages/messages_page.dart';

import '../../domain/announcement_entity.dart';

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

  @override
  Widget build(BuildContext context) {
    final announcement = widget.announcement;
    return Scaffold(
      appBar: AppBar(title: Text(announcement.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${announcement.city} · ${announcement.author}'),
            const SizedBox(height: 8),
            Text(
              '${announcement.province} · ${announcement.instrument}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (announcement.styles.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: announcement.styles.map((s) => Chip(label: Text(s))).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Text(announcement.body),
            const Spacer(),
            FilledButton.icon(
              onPressed: _isContacting ? null : _contactAuthor,
              icon: _isContacting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.message),
              label: Text(_isContacting ? 'Abriendo...' : 'Contactar autor'),
            ),
          ],
        ),
      ),
    );
  }
}
