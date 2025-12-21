import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/features/messaging/data/chat_repository.dart';
import 'package:upsessions/features/messaging/presentation/pages/messages_page.dart';
import 'package:upsessions/features/contacts/domain/liked_musician.dart';
import 'package:upsessions/features/contacts/presentation/widgets/musician_like_button.dart';

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
    final likedMusician = _mapToLikedMusician(musician);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: MusicianLikeButton(
              musician: likedMusician,
              iconSize: 28,
              padding: const EdgeInsets.all(4),
            ),
          ),
          _ProfileHeader(musician: musician),
          const SizedBox(height: 24),
          _HighlightsGrid(musician: musician),
          const SizedBox(height: 24),
          _StylesSection(styles: musician.styles),
          const SizedBox(height: 32),
          _ContactCard(
            isLoading: _isContacting,
            onPressed: _isContacting ? null : _contactMusician,
          ),
        ],
      ),
    );
  }

  LikedMusician _mapToLikedMusician(MusicianEntity musician) {
    return LikedMusician(
      id: musician.id,
      ownerId: musician.ownerId,
      name: musician.name,
      instrument: musician.instrument,
      city: musician.city,
      styles: musician.styles,
      photoUrl: musician.photoUrl,
      experienceYears: musician.experienceYears,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.musician});

  final MusicianEntity musician;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final initials = musician.name.isNotEmpty
        ? musician.name.trim().split(' ').take(2).map((word) => word[0]).join()
        : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.primary.withOpacity(0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                foregroundImage: musician.photoUrl?.isNotEmpty == true
                    ? NetworkImage(musician.photoUrl!)
                    : null,
                backgroundColor: colors.onPrimary.withOpacity(0.12),
                child: musician.photoUrl?.isNotEmpty == true
                    ? null
                    : Text(
                        initials,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      musician.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HeaderPill(
                          icon: Icons.music_note,
                          label: musician.instrument,
                        ),
                        _HeaderPill(
                          icon: Icons.location_on_outlined,
                          label: musician.city,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Disponible para eventos y colaboraciones',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onPrimary.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: colors.onPrimary.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.onPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightsGrid extends StatelessWidget {
  const _HighlightsGrid({required this.musician});

  final MusicianEntity musician;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Widget buildHighlight({
      required IconData icon,
      required String label,
      required String value,
    }) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colors.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500;
        final items = [
          buildHighlight(
            icon: Icons.work_history_outlined,
            label: 'Experiencia',
            value: '${musician.experienceYears} años',
          ),
          buildHighlight(
            icon: Icons.music_video,
            label: 'Instrumento',
            value: musician.instrument,
          ),
          buildHighlight(
            icon: Icons.place_outlined,
            label: 'Con base en',
            value: musician.city,
          ),
        ];
        if (isNarrow) {
          return Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                items[i],
                if (i != items.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: items[0]),
            const SizedBox(width: 12),
            Expanded(child: items[1]),
            const SizedBox(width: 12),
            Expanded(child: items[2]),
          ],
        );
      },
    );
  }
}

class _StylesSection extends StatelessWidget {
  const _StylesSection({required this.styles});

  final List<String> styles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estilos musicales',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (styles.isEmpty)
              Text(
                'Este músico aún no especificó estilos.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: styles
                    .map(
                      (style) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: colors.primary.withOpacity(0.08),
                        ),
                        child: Text(
                          style,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Te interesa colaborar?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Conecta por chat para coordinar detalles y disponibilidad.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onPressed,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.message_rounded),
              label: Text(isLoading ? 'Abriendo...' : 'Contactar'),
            ),
          ],
        ),
      ),
    );
  }
}
