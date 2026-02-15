import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upsessions/modules/announcements/cubits/announcement_form_cubit.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';

import '../../models/announcement_entity.dart';
import '../../repositories/announcements_repository.dart';
import 'announcement_form.dart';

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

    context.read<AnnouncementFormCubit>().submit(
      entity: entity,
      authorId: authorId,
      authorName: authorName,
      pickedImage: image,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnnouncementFormCubit(repository: repository),
      child: BlocConsumer<AnnouncementFormCubit, AnnouncementFormState>(
        listener: (context, state) {
          if (state.status == AnnouncementFormStatus.success) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Anuncio publicado')),
            );
          } else if (state.status == AnnouncementFormStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error al publicar anuncio: ${state.errorMessage}',
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Nuevo anuncio')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: AnnouncementForm(
                isLoading: state.status == AnnouncementFormStatus.submitting,
                onSubmit: (entity, image) => _submit(context, entity, image),
              ),
            ),
          );
        },
      ),
    );
  }
}
