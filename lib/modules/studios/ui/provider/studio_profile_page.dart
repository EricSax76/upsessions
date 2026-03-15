import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/core/locator/locator.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../cubits/my_studio_cubit.dart';
import '../../cubits/studio_media_cubit.dart';
import '../../cubits/studios_state.dart';
import '../../cubits/studios_status.dart';
import '../../models/studio_entity.dart';
import '../../repositories/studios_repository.dart';
import '../../services/studio_image_service.dart';
import '../widgets/studio_profile_form.dart';
import '../widgets/studio_profile_header.dart';

class StudioProfilePage extends StatefulWidget {
  const StudioProfilePage({super.key});

  @override
  State<StudioProfilePage> createState() => _StudioProfilePageState();
}

class _StudioProfilePageState extends State<StudioProfilePage> {
  bool _savePending = false;

  void _handleExit(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.go(AppRoutes.studiosDashboard);
  }

  void _save(BuildContext context, StudioEntity updatedStudio) {
    if (_savePending) return;
    setState(() => _savePending = true);
    context.read<MyStudioCubit>().updateMyStudio(updatedStudio);
  }

  void _handleSaveResult(BuildContext context, StudiosState state) {
    final loc = AppLocalizations.of(context);
    if (!_savePending) return;

    if (state.status == StudiosStatus.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.studioProfileUpdateSuccess)));
    } else if (state.status == StudiosStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? loc.studioProfileUpdateError),
        ),
      );
    }

    setState(() => _savePending = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StudioMediaCubit(
        repository: locate<StudiosRepository>(),
        imageService: locate<StudioImageService>(),
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<StudioMediaCubit, StudiosState>(
            listener: (context, state) {
              final loc = AppLocalizations.of(context);
              final updatedStudio = state.myStudio;
              if (state.status == StudiosStatus.success &&
                  updatedStudio != null) {
                context.read<MyStudioCubit>().replaceMyStudio(updatedStudio);
                return;
              }
              if (state.status == StudiosStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.errorMessage ?? loc.studioProfileImagesUpdateError,
                    ),
                  ),
                );
              }
            },
          ),
          BlocListener<MyStudioCubit, StudiosState>(
            listenWhen: (previous, current) {
              if (!_savePending) return false;
              final successTransition =
                  previous.status != StudiosStatus.success &&
                  current.status == StudiosStatus.success;
              final failureTransition =
                  previous.status != StudiosStatus.failure &&
                  current.status == StudiosStatus.failure;
              return successTransition || failureTransition;
            },
            listener: _handleSaveResult,
          ),
        ],
        child: BlocBuilder<MyStudioCubit, StudiosState>(
          builder: (context, state) {
            final loc = AppLocalizations.of(context);
            final studio = state.myStudio;
            if (studio == null) {
              return Center(child: Text(loc.studioProfileNotFound));
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
