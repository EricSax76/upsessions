import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/constants/app_spacing.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/core/widgets/app_card.dart';
import 'package:upsessions/core/widgets/date_badge.dart';
import 'package:upsessions/core/widgets/section_card.dart';
import 'package:upsessions/features/messaging/repositories/chat_repository.dart';
import 'package:upsessions/features/messaging/ui/pages/messages_page.dart';

import '../../models/announcement_entity.dart';

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
                      _AnnouncementImageCard(imageUrl: imageUrl),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    _AnnouncementHeaderCard(announcement: announcement),
                    const SizedBox(height: AppSpacing.lg),
                    _AnnouncementDescriptionCard(body: announcement.body),
                    if (announcement.styles.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _AnnouncementStylesCard(styles: announcement.styles),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    _AnnouncementContactCard(
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

class _AnnouncementImageCard extends StatelessWidget {
  const _AnnouncementImageCard({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: scheme.surfaceContainerHighest,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  color: scheme.onSurfaceVariant,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'Imagen no disponible',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnouncementHeaderCard extends StatelessWidget {
  const _AnnouncementHeaderCard({required this.announcement});

  final AnnouncementEntity announcement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final monthLabel = DateFormat.MMM(locale)
        .format(announcement.publishedAt)
        .toUpperCase();
    final dayLabel = DateFormat.d(locale).format(announcement.publishedAt);
    final author = announcement.author.trim();
    final location = _formatLocation(
      announcement.city,
      announcement.province,
    );
    final instrument = announcement.instrument.trim();

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSpacing.lg),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.campaign_outlined,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (author.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        author,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        location,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              DateBadge(month: monthLabel, day: dayLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (location.isNotEmpty)
                _InfoPill(
                  icon: Icons.place_outlined,
                  label: location,
                ),
              if (instrument.isNotEmpty)
                _InfoPill(
                  icon: Icons.music_note_outlined,
                  label: instrument,
                ),
            ],
          ),
          if (announcement.styles.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _ChipWrap(values: announcement.styles),
          ],
        ],
      ),
    );
  }
}

class _AnnouncementDescriptionCard extends StatelessWidget {
  const _AnnouncementDescriptionCard({required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final trimmed = body.trim();

    return SectionCard(
      title: 'Descripción',
      child: trimmed.isEmpty
          ? Text(
              'Este anuncio no tiene descripción.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            )
          : Text(
              trimmed,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
    );
  }
}

class _AnnouncementStylesCard extends StatelessWidget {
  const _AnnouncementStylesCard({required this.styles});

  final List<String> styles;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Estilos',
      child: _ChipWrap(values: styles),
    );
  }
}

class _AnnouncementContactCard extends StatelessWidget {
  const _AnnouncementContactCard({
    required this.author,
    required this.isLoading,
    required this.onContact,
  });

  final String author;
  final bool isLoading;
  final VoidCallback? onContact;

  @override
  Widget build(BuildContext context) {
    final label = author.trim().isEmpty
        ? 'Contactar autor'
        : 'Contactar a $author';

    return SectionCard(
      title: 'Contacto',
      subtitle: 'Inicia un chat directo con el autor del anuncio.',
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onContact,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.message_outlined),
          label: Text(isLoading ? 'Abriendo...' : label),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final trimmed = label.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: scheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              trimmed,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.values});

  final Iterable<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: values
          .where((value) => value.trim().isNotEmpty)
          .map(
            (value) => Chip(
              label: Text(value),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: scheme.surfaceContainerHighest,
              side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.65),
              ),
              labelStyle: theme.textTheme.labelMedium,
            ),
          )
          .toList(),
    );
  }
}

String _formatLocation(String city, String province) {
  final trimmedCity = city.trim();
  final trimmedProvince = province.trim();
  if (trimmedCity.isEmpty) return trimmedProvince;
  if (trimmedProvince.isEmpty) return trimmedCity;
  if (trimmedCity.toLowerCase() == trimmedProvince.toLowerCase()) {
    return trimmedCity;
  }
  return '$trimmedCity, $trimmedProvince';
}
