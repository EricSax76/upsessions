import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:upsessions/core/constants/app_routes.dart';
import 'package:upsessions/modules/musicians/repositories/affinity_options_repository.dart';
import 'package:upsessions/modules/musicians/repositories/artist_image_repository.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';
import 'package:upsessions/modules/profile/cubit/profile_form_cubit.dart';

import '../widgets/profile/profile_form.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({
    super.key,
    required this.affinityOptionsRepository,
    required this.artistImageRepository,
  });

  final AffinityOptionsRepository affinityOptionsRepository;
  final ArtistImageRepository artistImageRepository;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Error al actualizar el perfil',
              ),
            ),
          );
        }
        if (state.status == ProfileStatus.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        final isLoading = state.status == ProfileStatus.loading;

        if (isLoading && profile == null) {
          return Column(
            children: [
              const _EditProfileHeader(),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          );
        }

        if (profile == null) {
          return Column(
            children: [
              const _EditProfileHeader(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ?? 'No pudimos cargar tu perfil.',
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () =>
                            context.read<ProfileCubit>().refreshProfile(),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return BlocProvider(
          create: (_) => ProfileFormCubit(
            profile: profile,
            affinityRepository: affinityOptionsRepository,
            artistImageRepository: artistImageRepository,
          ),
          child: Builder(
            builder: (context) {
              final formCubit = context.read<ProfileFormCubit>();
              return Column(
                children: [
                  _EditProfileHeader(
                    onSave: isLoading
                        ? null
                        : () async {
                            final ageGateError = formCubit.validateAgeGate();
                            if (ageGateError != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(ageGateError)),
                              );
                              return;
                            }
                            await context.read<ProfileCubit>().updateProfile(
                              formCubit.getUpdatedProfile(profile),
                            );
                            if (!context.mounted) return;
                            if (context.read<ProfileCubit>().state.status ==
                                ProfileStatus.success) {
                              context.go(AppRoutes.profile);
                            }
                          },
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: ProfileForm(),
                        ),
                        if (isLoading)
                          Positioned.fill(
                            child: ColoredBox(
                              color: Theme.of(context).colorScheme.scrim,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader({this.onSave});

  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Editar perfil',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (onSave != null)
            IconButton(
              onPressed: onSave,
              icon: const Icon(Icons.check),
              tooltip: 'Guardar cambios',
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
