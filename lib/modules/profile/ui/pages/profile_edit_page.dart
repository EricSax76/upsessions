import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/modules/musicians/repositories/affinity_options_repository.dart';
import 'package:upsessions/modules/profile/cubit/profile_cubit.dart';

import '../widgets/profile/profile_form.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({
    super.key,
    required this.affinityOptionsRepository,
  });

  final AffinityOptionsRepository affinityOptionsRepository;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error al actualizar el perfil'),
            ),
          );
        }
        if (state.status == ProfileStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado')),
          );
        }
      },
      builder: (context, state) {
        final profile = state.profile;

        Widget body;
        if (state.status == ProfileStatus.loading && profile == null) {
          body = const Center(child: CircularProgressIndicator());
        } else if (profile == null) {
          body = Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.errorMessage ?? 'No pudimos cargar tu perfil.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.read<ProfileCubit>().refreshProfile(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        } else {
          body = Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ProfileForm(
                  profile: profile,
                  onSave: (updated) =>
                      context.read<ProfileCubit>().updateProfile(updated),
                  affinityRepository: affinityOptionsRepository,
                ),
              ),
              if (state.status == ProfileStatus.loading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Editar perfil',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed:
                        () => context.read<ProfileCubit>().refreshProfile(),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Recargar perfil',
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        );
      },
    );
  }
}
