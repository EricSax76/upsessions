import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../auth/cubits/auth_cubit.dart';
import '../../../../home/ui/widgets/profile/profile_link_box.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final ImagePicker _picker = ImagePicker();
  bool _twoFactor = false;
  bool _newsletter = true;
  bool _uploadingPhoto = false;
  bool _profileRequested = false;

  Future<void> _changePhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxHeight: 1200,
        maxWidth: 1200,
      );
      if (file == null) {
        return;
      }
      setState(() => _uploadingPhoto = true);
      final bytes = await file.readAsBytes();
      final extension = _extensionFromName(file.name);
      if (!mounted) return;
      final authCubit = context.read<AuthCubit>();
      await authCubit.updateProfilePhoto(bytes, fileExtension: extension);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Foto actualizada')));
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la foto: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Seleccionar de la galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _changePhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Usar la cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  _changePhoto(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static String _extensionFromName(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toLowerCase();
    }
    return 'jpg';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          context.go(AppRoutes.login);
        }
      },
      builder: (context, state) {
        final profile = state.profile;
        final user = state.user;
        final isLoadingProfile =
            state.isLoading && state.lastAction == AuthAction.loadProfile;
        final loadError = state.lastAction == AuthAction.loadProfile
            ? state.errorMessage
            : null;
        if (!_profileRequested &&
            user != null &&
            profile == null &&
            !isLoadingProfile) {
          _profileRequested = true;
          context.read<AuthCubit>().refreshProfile();
        }
        if (profile == null || user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Mi cuenta')),
            body: Center(
              child: isLoadingProfile
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_off, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            loadError ??
                                'No pudimos cargar tu perfil en este momento.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              _profileRequested = false;
                              context.read<AuthCubit>().refreshProfile();
                            },
                            child: const Text('Reintentar'),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.read<AuthCubit>().signOut(),
                            child: const Text('Cerrar sesión'),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        }
        final avatarUrl = profile.photoUrl ?? user.photoUrl;
        return Scaffold(
          appBar: AppBar(title: const Text('Mi cuenta')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundImage: avatarUrl != null
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl == null
                                  ? const Icon(Icons.person, size: 48)
                                  : null,
                            ),
                            if (_uploadingPhoto)
                              const Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _uploadingPhoto ? null : _showPhotoOptions,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Cambiar foto'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push(AppRoutes.profileEdit),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Actualizar perfil'),
                  ),
                ),
                const SizedBox(height: 16),
                const ProfileLinkBox(),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalles del perfil',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _AccountField(label: 'Biografía', value: profile.bio),
                        const Divider(),
                        _AccountField(
                          label: 'Ubicación',
                          value: profile.location,
                        ),
                        const Divider(),
                        _AccountField(
                          label: 'Habilidades',
                          value: profile.skills.isNotEmpty
                              ? profile.skills.join(', ')
                              : 'Sin habilidades registradas',
                        ),
                        const Divider(),
                        _AccountField(
                          label: 'Enlaces',
                          value: profile.links.isNotEmpty
                              ? profile.links.entries
                                    .map((e) => '${e.key}: ${e.value}')
                                    .join('\n')
                              : 'Sin enlaces',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _twoFactor,
                        title: const Text('Autenticación de dos pasos'),
                        onChanged: (value) =>
                            setState(() => _twoFactor = value),
                      ),
                      const Divider(height: 0),
                      SwitchListTile(
                        value: _newsletter,
                        title: const Text('Recibir boletines'),
                        onChanged: (value) =>
                            setState(() => _newsletter = value),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Cerrar sesión'),
                        onTap: () => context.read<AuthCubit>().signOut(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AccountField extends StatelessWidget {
  const _AccountField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
