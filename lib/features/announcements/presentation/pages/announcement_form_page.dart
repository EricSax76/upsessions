import 'package:flutter/material.dart';

import '../../data/announcements_repository.dart';
import '../../domain/announcement_entity.dart';
import '../widgets/announcement_form.dart';

class AnnouncementFormPage extends StatelessWidget {
  const AnnouncementFormPage({super.key, required this.repository});

  final AnnouncementsRepository repository;

  Future<void> _submit(BuildContext context, AnnouncementEntity entity) async {
    await repository.create(entity);
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anuncio publicado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo anuncio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnnouncementForm(onSubmit: (entity) => _submit(context, entity)),
      ),
    );
  }
}
