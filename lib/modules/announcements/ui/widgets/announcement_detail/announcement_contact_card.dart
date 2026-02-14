import 'package:flutter/material.dart';
import 'package:upsessions/core/widgets/section_card.dart';

class AnnouncementContactCard extends StatelessWidget {
  const AnnouncementContactCard({
    super.key,
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
