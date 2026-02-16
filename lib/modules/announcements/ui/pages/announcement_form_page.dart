import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upsessions/modules/announcements/cubits/announcement_form_cubit.dart';
import 'package:upsessions/modules/auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';

import '../../models/announcement_entity.dart';
import '../../repositories/announcements_repository.dart';
import '../../services/announcement_image_service.dart';
import 'announcement_form.dart';

class AnnouncementFormPage extends StatelessWidget {
  const AnnouncementFormPage({
    super.key,
    required this.repository,
    required this.imageService,
  });

  final AnnouncementsRepository repository;
  final AnnouncementImageService imageService;

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
      create:
          (context) => AnnouncementFormCubit(
            repository: repository,
            imageService: imageService,
          ),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nuevo anuncio',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    AnnouncementForm(
                      isLoading:
                          state.status == AnnouncementFormStatus.submitting,
                      onSubmit:
                          (entity, image) => _submit(context, entity, image),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
