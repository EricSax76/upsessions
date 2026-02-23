import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';

import '../../cubits/my_studio_cubit.dart';
import '../../cubits/studio_media_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../models/studio_entity.dart';
import '../../repositories/studios_repository.dart';
import '../../services/studio_image_service.dart';
import '../widgets/studio_profile_form.dart';
import '../widgets/studio_profile_header.dart';

class StudioProfilePage extends StatelessWidget {
  const StudioProfilePage({super.key});

  void _handleExit(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.go(AppRoutes.studiosDashboard);
  }

  void _save(BuildContext context, StudioEntity updatedStudio) {
    context.read<MyStudioCubit>().updateMyStudio(updatedStudio);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudioMediaCubit(
        repository: locate<StudiosRepository>(),
        imageService: locate<StudioImageService>(),
      ),
      child: BlocListener<StudioMediaCubit, StudiosState>(
        listener: (context, state) {
          final updatedStudio = state.myStudio;
          if (state.status == StudiosStatus.success && updatedStudio != null) {
            context.read<MyStudioCubit>().replaceMyStudio(updatedStudio);
            return;
          }
          if (state.status == StudiosStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ??
                      'No se pudieron actualizar las imagenes.',
                ),
              ),
            );
          }
        },
        child: BlocBuilder<MyStudioCubit, StudiosState>(
          builder: (context, state) {
            final studio = state.myStudio;
            if (studio == null) {
              return const Center(child: Text('No studio found'));
            }

            return CustomScrollView(
              slivers: [
                StudioProfileHeader(
                  studio: studio,
                  onExit: () => _handleExit(context),
                  onUploadBanner: () => context
                      .read<StudioMediaCubit>()
                      .uploadStudioBanner(studio),
                  onUploadLogo: () =>
                      context.read<StudioMediaCubit>().uploadStudioLogo(studio),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        StudioAvatarSection(
                          studio: studio,
                          onUploadLogo: () => context
                              .read<StudioMediaCubit>()
                              .uploadStudioLogo(studio),
                        ),
                        const SizedBox(height: 24),
                        StudioProfileForm(
                          studio: studio,
                          onSave: (updated) => _save(context, updated),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
