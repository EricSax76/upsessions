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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crea una ficha utilitaria',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Completa los campos clave y obtén un texto que puedes pegar en un archivo plano o enviar por WhatsApp/Email.',
          style: Theme.of(context).textTheme.bodyLarge,
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
