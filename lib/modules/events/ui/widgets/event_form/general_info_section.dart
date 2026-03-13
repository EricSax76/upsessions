import 'package:flutter/material.dart';
import '../../../../../core/widgets/gap.dart';
import '../../../../../core/widgets/section_card.dart';
import 'event_form_field.dart';

class GeneralInfoSection extends StatelessWidget {
  const GeneralInfoSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.tagsController,
  });

  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController tagsController;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Información general',
      child: Column(
        children: [
          EventFormField(
            controller: titleController,
            label: 'Título del evento',
            icon: Icons.title,
            validator: (value) =>
                value != null && value.trim().isNotEmpty ? null : 'Requerido',
          ),
          const VSpace(12),
          EventFormField(
            controller: descriptionController,
            label: 'Descripción',
            icon: Icons.short_text,
            minLines: 3,
            maxLines: 4,
          ),
          const VSpace(12),
          EventFormField(
            controller: tagsController,
            label: 'Tags (separados por coma)',
            icon: Icons.tag,
          ),
        ],
      ),
    );
  }
}
