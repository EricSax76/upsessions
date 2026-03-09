import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upsessions/core/widgets/sm_avatar.dart';
import 'package:upsessions/modules/profile/ui/dialogs/account_photo_options_sheet.dart';
import 'package:upsessions/modules/profile/ui/widgets/account/account_photo_flow.dart';

import '../../cubits/event_manager_auth_cubit.dart';
import '../../cubits/event_manager_auth_state.dart';
import '../../models/event_manager_entity.dart';

class ManagerProfilePage extends StatefulWidget {
  const ManagerProfilePage({super.key});

  @override
  State<ManagerProfilePage> createState() => _ManagerProfilePageState();
}

class _ManagerProfilePageState extends State<ManagerProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final AccountPhotoFlow _photoFlow = AccountPhotoFlow();

  Uint8List? _pendingPhotoBytes;
  String? _pendingPhotoExtension;
  String? _boundManagerId;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _openPhotoOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => const AccountPhotoOptionsSheet(),
    );
    if (!mounted || source == null) return;
    await _pickAndStagePhoto(source);
  }

  Future<void> _pickAndStagePhoto(ImageSource source) async {
    try {
      final file = await _photoFlow.pickProfilePhoto(source);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pendingPhotoBytes = bytes;
        _pendingPhotoExtension = AccountPhotoFlow.extensionFromName(file.name);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto seleccionada. Pulsa "Guardar cambios".'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo seleccionar la foto: $error')),
      );
    }
  }

  Future<void> _saveChanges(EventManagerEntity manager) async {
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final cubit = context.read<EventManagerAuthCubit>();
    await cubit.updateProfile(
      managerName: trimmedName,
      photoBytes: _pendingPhotoBytes,
      photoExtension: _pendingPhotoExtension ?? 'jpg',
    );

    if (!mounted) return;
    final updatedState = cubit.state;
    if (updatedState.status == EventManagerAuthStatus.authenticated) {
      setState(() {
        _pendingPhotoBytes = null;
        _pendingPhotoExtension = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cambios guardados.')));
    } else if (updatedState.status == EventManagerAuthStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedState.errorMessage ?? 'No se pudieron guardar los cambios.',
          ),
        ),
      );
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
  }

  void _syncNameController(EventManagerEntity manager) {
    if (_boundManagerId != manager.id) {
      _boundManagerId = manager.id;
      _nameController.text = manager.name;
      return;
    }

    if (_nameController.text.isEmpty) {
      _nameController.text = manager.name;
    }
  }

  String _buildInitials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2)
        .toList(growable: false);
    if (words.isEmpty) return '';
    return words.map((word) => word[0].toUpperCase()).join();
  }

  String _cityLabel(EventManagerEntity manager) {
    final city = manager.city.trim();
    final province = (manager.province ?? '').trim();
    if (city.isEmpty && province.isEmpty) return 'No disponible';
    if (province.isEmpty) return city;
    if (city.isEmpty) return province;
    return '$city, $province';
  }

  Widget _buildAvatar(EventManagerEntity manager) {
    final pendingPhoto = _pendingPhotoBytes;
    if (pendingPhoto != null) {
      return ClipOval(
        child: Image.memory(
          pendingPhoto,
          width: 104,
          height: 104,
          fit: BoxFit.cover,
        ),
      );
    }
    return SmAvatar(
      radius: 52,
      imageUrl: manager.logoUrl,
      initials: _buildInitials(manager.name),
      fallbackIcon: Icons.store_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventManagerAuthCubit, EventManagerAuthState>(
      builder: (context, state) {
        final manager = state.manager;
        if (manager == null && state.status == EventManagerAuthStatus.loading) {
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

        _syncNameController(manager);

        final trimmedName = _nameController.text.trim();
        final hasNameChanges = trimmedName != manager.name.trim();
        final hasPhotoChanges = _pendingPhotoBytes != null;
        final isProcessingState =
            state.status == EventManagerAuthStatus.loading;
        final isBusy = _isSaving || isProcessingState;
        final canSave =
            !isBusy &&
            trimmedName.isNotEmpty &&
            (hasNameChanges || hasPhotoChanges);

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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _buildAvatar(manager),
                                Positioned(
                                  right: -4,
                                  bottom: -4,
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    child: IconButton(
                                      onPressed: isBusy
                                          ? null
                                          : _openPhotoOptions,
                                      icon: Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                      tooltip: 'Cambiar foto',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Foto del perfil',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sube una imagen y guarda para aplicar cambios.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Datos básicos de registro',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              enabled: !isBusy,
                              textCapitalization: TextCapitalization.words,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(
                                labelText: 'Nombre del manager / productora',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              key: ValueKey('email-${manager.contactEmail}'),
                              initialValue: manager.contactEmail,
                              enabled: false,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Correo de registro',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              key: ValueKey('phone-${manager.contactPhone}'),
                              initialValue: manager.contactPhone,
                              enabled: false,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              key: ValueKey(
                                'city-${manager.id}-${_cityLabel(manager)}',
                              ),
                              initialValue: _cityLabel(manager),
                              enabled: false,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Ciudad',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: canSave
                                    ? () => _saveChanges(manager)
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    isBusy ? 'Guardando...' : 'Guardar cambios',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
