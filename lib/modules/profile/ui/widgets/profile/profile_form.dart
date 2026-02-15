import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:upsessions/modules/auth/models/profile_entity.dart';
import 'package:upsessions/modules/musicians/repositories/affinity_options_repository.dart';
import 'package:upsessions/modules/profile/cubit/profile_form_cubit.dart';
import 'profile_basic_info_fields.dart';
import 'profile_affinity_section.dart';

class ProfileForm extends StatelessWidget {
  const ProfileForm({
    super.key,
    required this.profile,
    required this.onSave,
    required this.affinityRepository,
  });

  final ProfileEntity profile;
  final ValueChanged<ProfileEntity> onSave;
  final AffinityOptionsRepository affinityRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileFormCubit(
        profile: profile,
        affinityRepository: affinityRepository,
      ),
      child: Builder(
        builder: (context) {
          final cubit = context.read<ProfileFormCubit>();
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ProfileBasicInfoFields(),
                const SizedBox(height: 24),
                const ProfileAffinitySection(),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => onSave(cubit.getUpdatedProfile(profile)),
                    child: const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
