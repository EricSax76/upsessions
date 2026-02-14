import 'package:flutter/material.dart';

import '../../../models/event_entity.dart';
import 'event_detail_components.dart';
import 'event_detail_helpers.dart';

class EventDescriptionSection extends StatelessWidget {
  const EventDescriptionSection({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return EventSectionCard(
      icon: Icons.description_outlined,
      title: 'Descripción',
      child: Text(
        event.description,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
      ),
    );
  }
}

class EventContactSection extends StatelessWidget {
  const EventContactSection({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return EventSectionCard(
      icon: Icons.contact_page_outlined,
      title: 'Contacto',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          EventCopyPill(
            icon: Icons.email_outlined,
            label: event.contactEmail,
            onCopy: () => copyToClipboard(
              context,
              event.contactEmail,
              message: 'Email copiado',
            ),
          ),
          EventCopyPill(
            icon: Icons.phone_outlined,
            label: event.contactPhone,
            onCopy: () => copyToClipboard(
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

class EventLineupSection extends StatelessWidget {
  const EventLineupSection({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return EventSectionCard(
      icon: Icons.queue_music_outlined,
      title: 'Lineup',
      child: event.lineup.isEmpty
          ? const EventEmptySection(
              icon: Icons.music_off_outlined,
              message: 'Aún no hay artistas confirmados.',
            )
          : EventChipWrap(values: event.lineup),
    );
  }
}

class EventTagsSection extends StatelessWidget {
  const EventTagsSection({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return EventSectionCard(
      icon: Icons.local_offer_outlined,
      title: 'Etiquetas',
      child: event.tags.isEmpty
          ? const EventEmptySection(
              icon: Icons.sell_outlined,
              message: 'Sin etiquetas asociadas.',
            )
          : EventChipWrap(values: event.tags),
    );
  }
}

class EventResourcesSection extends StatelessWidget {
  const EventResourcesSection({super.key, required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    return EventSectionCard(
      icon: Icons.build_outlined,
      title: 'Recursos necesarios',
      child: event.resources.isEmpty
          ? const EventEmptySection(
              icon: Icons.handyman_outlined,
              message: 'Sin recursos registrados.',
            )
          : EventChipWrap(values: event.resources),
    );
  }
}

class EventNotesSection extends StatelessWidget {
  const EventNotesSection({super.key, required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return EventSectionCard(
      icon: Icons.sticky_note_2_outlined,
      title: 'Notas',
      child: Text(
        notes,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
      ),
    );
  }
}
