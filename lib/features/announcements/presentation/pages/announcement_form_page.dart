import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/announcements_repository.dart';
import '../../domain/announcement_entity.dart';
import '../../../auth/application/auth_cubit.dart';
import '../widgets/announcement_form.dart';

class AnnouncementFormPage extends StatelessWidget {
  const AnnouncementFormPage({super.key, required this.repository});

  final AnnouncementsRepository repository;

  Future<void> _submit(BuildContext context, AnnouncementEntity entity) async {
    final authState = context.read<AuthCubit>().state;
    final user = authState.user;
    final profile = authState.profile;
    final authorId = user?.id ?? '';
    final authorName = profile?.name ?? user?.displayName ?? 'Autor';

    final enriched = entity.copyWith(
      authorId: authorId,
      author: authorName,
    );

    await repository.create(enriched);
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
