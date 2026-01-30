import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:image_picker/image_picker.dart';
import '../../data/announcement_image_service.dart';
import '../../data/announcements_repository.dart';
import '../../domain/announcement_entity.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';
import '../widgets/announcement_form.dart';

class AnnouncementFormPage extends StatelessWidget {
  const AnnouncementFormPage({super.key, required this.repository});

  final AnnouncementsRepository repository;

  Future<void> _submit(
    BuildContext context,
    AnnouncementEntity entity,
    XFile? image,
  ) async {
    final authState = context.read<AuthCubit>().state;
    final user = authState.user;
    final profile = context.read<ProfileCubit>().state.profile;
    final authorId = user?.id ?? '';
    final authorName = profile?.name ?? user?.displayName ?? 'Autor';

    final enriched = entity.copyWith(authorId: authorId, author: authorName);

    // Subir imagen si existe
    String? imageUrl;
    if (image != null) {
      try {
        final imageService = AnnouncementImageService();
        imageUrl = await imageService.uploadImage(image);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir imagen: $e')),
          );
        }
        return;
      }
    }

    await repository.create(enriched.copyWith(imageUrl: imageUrl));
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Anuncio publicado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo anuncio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnnouncementForm(
          onSubmit: (entity, image) => _submit(context, entity, image),
        ),
      ),
    );
  }
}
