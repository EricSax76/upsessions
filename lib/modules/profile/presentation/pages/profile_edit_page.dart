import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/cubits/auth_cubit.dart';
import 'package:upsessions/modules/auth/domain/profile_entity.dart';
import '../widgets/profile_form.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  Future<void> _save(BuildContext context, ProfileEntity profile) async {
    final cubit = context.read<AuthCubit>();
    await cubit.updateProfile(profile);
    if (!context.mounted) return;
    final state = cubit.state;
    final isError =
        state.lastAction == AuthAction.updateProfile &&
        state.errorMessage != null;
    if (isError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      cubit.clearMessages();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final profile = state.profile;
        final updating =
            state.isLoading && state.lastAction == AuthAction.updateProfile;

        Widget body;
        if (profile == null) {
          final isLoadingProfile =
              state.isLoading && state.lastAction == AuthAction.loadProfile;
          final error = state.lastAction == AuthAction.loadProfile
              ? state.errorMessage
              : null;
          body = Center(
            child: isLoadingProfile
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error ?? 'No pudimos cargar tu perfil.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () =>
                            context.read<AuthCubit>().refreshProfile(),
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
                  onSave: (updated) => _save(context, updated),
                ),
              ),
              if (updating)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Editar perfil'),
            actions: [
              IconButton(
                onPressed: () => context.read<AuthCubit>().refreshProfile(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Recargar perfil',
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }
}
