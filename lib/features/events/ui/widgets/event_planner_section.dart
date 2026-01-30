import 'package:flutter/material.dart';

import '../../models/event_entity.dart';
import 'event_form_card.dart';
import 'event_text_template_card.dart';

class EventPlannerSection extends StatelessWidget {
  const EventPlannerSection({
    super.key,
    required this.preview,
    required this.onGenerateDraft,
    required this.ownerId,
  });

  final EventEntity? preview;
  final ValueChanged<EventEntity> onGenerateDraft;
  final String? ownerId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.edit_calendar_rounded,
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crea un evento tipo plantilla',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Completa los campos clave y obtén un texto que puedes pegar en un archivo plano o enviar por WhatsApp/Email.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: EventFormCard(
                      onGenerateDraft: onGenerateDraft,
                      ownerId: ownerId,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(child: EventTextTemplateCard(event: preview)),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventFormCard(
                  onGenerateDraft: onGenerateDraft,
                  ownerId: ownerId,
                ),
                const SizedBox(height: 24),
                EventTextTemplateCard(event: preview),
              ],
            );
          },
        ),
      ],
    );
  }
}
