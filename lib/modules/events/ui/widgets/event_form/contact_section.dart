import 'package:flutter/material.dart';
import '../../../../../core/widgets/gap.dart';
import '../../../../../core/widgets/section_card.dart';
import 'event_form_field.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({
    super.key,
    required this.organizerController,
    required this.contactEmailController,
    required this.contactPhoneController,
    required this.notesController,
  });

  final TextEditingController organizerController;
  final TextEditingController contactEmailController;
  final TextEditingController contactPhoneController;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Contacto',
      child: Column(
        children: [
          EventFormField(
            controller: organizerController,
            label: 'Organizador',
            icon: Icons.person,
          ),
          const VSpace(12),
          EventFormField(
            controller: contactEmailController,
            label: 'Email',
            icon: Icons.email,
          ),
          const VSpace(12),
          EventFormField(
            controller: contactPhoneController,
            label: 'Teléfono',
            icon: Icons.phone,
          ),
          const VSpace(12),
          EventFormField(
            controller: notesController,
            label: 'Notas adicionales',
            icon: Icons.note,
            minLines: 2,
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
