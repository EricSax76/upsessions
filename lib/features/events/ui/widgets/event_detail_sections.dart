part of '../pages/event_detail_page.dart';

class _EventDetailList extends StatelessWidget {
  const _EventDetailList({
    required this.event,
    required this.meta,
    required this.isUploadingBanner,
    required this.onUploadBanner,
    required this.onCopyTemplate,
    required this.onShare,
    required this.horizontalPadding,
  });

  final EventEntity event;
  final _EventDetailMeta meta;
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
        _EventBanner(
          imageUrl: event.bannerImageUrl,
          isUploading: isUploadingBanner,
          onUpload: onUploadBanner,
          eventTitle: event.title,
        ),
        if (event.bannerImageUrl != null) const SizedBox(height: 16),
        _EventHeaderCard(event: event, meta: meta),
        const SizedBox(height: 16),
        _EventDescriptionSection(event: event),
        const SizedBox(height: 12),
        _EventContactSection(event: event),
        const SizedBox(height: 12),
        _EventLineupSection(event: event),
        const SizedBox(height: 12),
        _EventTagsSection(event: event),
        const SizedBox(height: 12),
        _EventResourcesSection(event: event),
        if (event.notes?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _EventNotesSection(notes: event.notes!),
        ],
        const SizedBox(height: 16),
        _EventQuickActionsSection(onCopyTemplate: onCopyTemplate),
        const SizedBox(height: 12),
        _EventActionButtons(onShare: onShare, onCopyTemplate: onCopyTemplate),
      ],
    );
  }
}

class _EventHeaderCard extends StatelessWidget {
  const _EventHeaderCard({required this.event, required this.meta});

  final EventEntity event;
  final _EventDetailMeta meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    Icons.event_available_outlined,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.dateLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${meta.startTime} - ${meta.endTime}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${event.venue} · ${event.city}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _InfoPill(
                  icon: Icons.group_outlined,
                  label: '${event.capacity} personas',
                ),
                if (event.ticketInfo.trim().isNotEmpty)
                  _InfoPill(
                    icon: Icons.confirmation_number_outlined,
                    label: event.ticketInfo,
                  ),
                _InfoPill(
                  icon: Icons.person_outline,
                  label: event.organizer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventDescriptionSection extends StatelessWidget {
  const _EventDescriptionSection({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      icon: Icons.description_outlined,
      title: 'Descripción',
      child: Text(
        event.description,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
    );
  }
}

class _EventContactSection extends StatelessWidget {
  const _EventContactSection({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.contact_page_outlined,
      title: 'Contacto',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _CopyPill(
            icon: Icons.email_outlined,
            label: event.contactEmail,
            onCopy: () => _copyToClipboard(
              context,
              event.contactEmail,
              message: 'Email copiado',
            ),
          ),
          _CopyPill(
            icon: Icons.phone_outlined,
            label: event.contactPhone,
            onCopy: () => _copyToClipboard(
              context,
              event.contactPhone,
              message: 'Teléfono copiado',
            ),
          ),
        ],
      ),
    );
  }
}

class _EventLineupSection extends StatelessWidget {
  const _EventLineupSection({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.queue_music_outlined,
      title: 'Lineup',
      child: event.lineup.isEmpty
          ? const _EmptySection(
              icon: Icons.music_off_outlined,
              message: 'Aún no hay artistas confirmados.',
            )
          : _ChipWrap(values: event.lineup),
    );
  }
}

class _EventTagsSection extends StatelessWidget {
  const _EventTagsSection({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.local_offer_outlined,
      title: 'Etiquetas',
      child: event.tags.isEmpty
          ? const _EmptySection(
              icon: Icons.sell_outlined,
              message: 'Sin etiquetas asociadas.',
            )
          : _ChipWrap(values: event.tags),
    );
  }
}

class _EventResourcesSection extends StatelessWidget {
  const _EventResourcesSection({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.build_outlined,
      title: 'Recursos necesarios',
      child: event.resources.isEmpty
          ? const _EmptySection(
              icon: Icons.handyman_outlined,
              message: 'Sin recursos registrados.',
            )
          : _ChipWrap(values: event.resources),
    );
  }
}

class _EventNotesSection extends StatelessWidget {
  const _EventNotesSection({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      icon: Icons.sticky_note_2_outlined,
      title: 'Notas',
      child: Text(
        notes,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
      ),
    );
  }
}

class _EventQuickActionsSection extends StatelessWidget {
  const _EventQuickActionsSection({required this.onCopyTemplate});

  final Future<void> Function() onCopyTemplate;

  @override
  Widget build(BuildContext context) {
    return EmptyStateCard(
      icon: Icons.tips_and_updates_outlined,
      title: 'Acciones rápidas',
      subtitle: 'Comparte o copia la ficha del evento en texto.',
      trailing: IconButton(
        tooltip: 'Copiar formato',
        onPressed: () => onCopyTemplate(),
        icon: const Icon(Icons.copy_all_outlined),
      ),
    );
  }
}

class _EventActionButtons extends StatelessWidget {
  const _EventActionButtons({
    required this.onShare,
    required this.onCopyTemplate,
  });

  final VoidCallback onShare;
  final Future<void> Function() onCopyTemplate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Compartir ficha'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => onCopyTemplate(),
            icon: const Icon(Icons.copy_all_outlined),
            label: const Text('Copiar formato'),
          ),
        ),
      ],
    );
  }
}
