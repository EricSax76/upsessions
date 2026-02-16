import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';

import '../../cubits/studios_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../models/studio_entity.dart';
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
    context.read<StudiosCubit>().updateMyStudio(updatedStudio);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudiosCubit, StudiosState>(
      builder: (context, state) {
        final studio = state.myStudio;
        if (studio == null) {
        if (studio == null) {
          return const Center(child: Text('No studio found'));
        }
        }

        return CustomScrollView(
          slivers: [
            StudioProfileHeader(
              studio: studio,
              onExit: () => _handleExit(context),
              onUploadBanner: () => context
                  .read<StudiosCubit>()
                  .uploadMyStudioBanner(studio.id),
              onUploadLogo: () => context
                  .read<StudiosCubit>()
                  .uploadMyStudioLogo(studio.id),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Using the AvatarSection from header file (or extracted separately)
                    // Ideally AvatarSection should be public in header file
                    StudioAvatarSection(
                      studio: studio,
                      onUploadLogo: () => context
                          .read<StudiosCubit>()
                          .uploadMyStudioLogo(studio.id),
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
    );
  }
}

