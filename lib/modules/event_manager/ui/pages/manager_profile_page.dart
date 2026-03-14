import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upsessions/modules/profile/ui/dialogs/account_photo_options_sheet.dart';

import '../../cubits/event_manager_auth_cubit.dart';
import '../../cubits/event_manager_auth_state.dart';
import '../../cubits/manager_profile_cubit.dart';
import '../../cubits/manager_profile_state.dart';
import '../widgets/profile/manager_avatar_card.dart';
import '../widgets/profile/manager_basic_data_card.dart';
import '../widgets/profile/manager_profile_helpers.dart';

class ManagerProfilePage extends StatelessWidget {
  const ManagerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManagerProfileCubit(
        authCubit: context.read<EventManagerAuthCubit>(),
      ),
      child: const _ManagerProfileView(),
    );
  }
}

class _ManagerProfileView extends StatefulWidget {
  const _ManagerProfileView();

  @override
  State<_ManagerProfileView> createState() => _ManagerProfileViewState();
}

class _ManagerProfileViewState extends State<_ManagerProfileView> {
  final TextEditingController _nameController = TextEditingController();
  String? _boundManagerId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _syncNameController(String id, String name) {
    if (_boundManagerId != id) {
      _boundManagerId = id;
      _nameController.text = name;
      return;
    }
    if (_nameController.text.isEmpty) {
      _nameController.text = name;
    }
  }

  Future<void> _openPhotoOptions(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => const AccountPhotoOptionsSheet(),
    );
    if (!context.mounted || source == null) return;
    context.read<ManagerProfileCubit>().stagePhoto(source);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManagerProfileCubit, ManagerProfileState>(
      listenWhen: (previous, current) =>
          current.feedbackMessage != null &&
          current.feedbackMessage != previous.feedbackMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.feedbackMessage!)),
        );
        context.read<ManagerProfileCubit>().clearFeedback();
      },
      child: BlocBuilder<EventManagerAuthCubit, EventManagerAuthState>(
        builder: (context, authState) {
          final manager = authState.manager;

          if (manager == null &&
              authState.status == EventManagerAuthStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (manager == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudo cargar el perfil del manager.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        context.read<EventManagerAuthCubit>().loadProfile(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          _syncNameController(manager.id, manager.name);

          return BlocBuilder<ManagerProfileCubit, ManagerProfileState>(
            builder: (context, profileState) {
              final trimmedName = _nameController.text.trim();
              final isBusy = profileState.isSaving ||
                  authState.status == EventManagerAuthStatus.loading;
              final canSave = !isBusy &&
                  trimmedName.isNotEmpty &&
                  (trimmedName != manager.name.trim() ||
                      profileState.hasPendingPhoto);

              return Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Perfil',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          ManagerAvatarCard(
                            initials: buildManagerInitials(manager.name),
                            isBusy: isBusy,
                            onChangeTap: () => _openPhotoOptions(context),
                            pendingPhotoBytes: profileState.pendingPhotoBytes,
                            imageUrl: manager.logoUrl,
                          ),
                          const SizedBox(height: 16),
                          ManagerBasicDataCard(
                            manager: manager,
                            nameController: _nameController,
                            isBusy: isBusy,
                            canSave: canSave,
                            onSave: () => context
                                .read<ManagerProfileCubit>()
                                .saveChanges(_nameController.text),
                            onNameChanged: () => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
