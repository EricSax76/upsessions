import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/messaging/data/chat_repository.dart';
import 'package:upsessions/features/messaging/presentation/pages/messages_page.dart';

import '../../domain/musician_entity.dart';

class MusicianDetailPage extends StatefulWidget {
  const MusicianDetailPage({super.key, required this.musician});

  final MusicianEntity musician;

  @override
  State<MusicianDetailPage> createState() => _MusicianDetailPageState();
}

class _MusicianDetailPageState extends State<MusicianDetailPage> {
  final ChatRepository _chatRepository = locate();
  bool _isContacting = false;

  Future<void> _contactMusician() async {
    setState(() => _isContacting = true);
    try {
      final musician = widget.musician;
      final participantId = musician.ownerId.isNotEmpty
          ? musician.ownerId
          : musician.id;
      final thread = await _chatRepository.ensureThreadWithParticipant(
        participantId: participantId,
        participantName: musician.name,
      );
      if (!mounted) return;
      context.push(
        AppRoutes.messages,
        extra: MessagesPageArgs(initialThreadId: thread.id),
      );
    } catch (error) {
      print('Error contacting musician: $error');
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
    final musician = widget.musician;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            musician.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${musician.instrument} · ${musician.city}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: musician.styles
                .map((style) => Chip(label: Text(style)))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Experiencia: ${musician.experienceYears} años',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isContacting ? null : _contactMusician,
            icon: _isContacting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.message),
            label: Text(_isContacting ? 'Abriendo...' : 'Contactar'),
          ),
        ],
      ),
    );
  }
}
