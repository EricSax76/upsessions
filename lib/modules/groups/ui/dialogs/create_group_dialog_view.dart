import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../cubits/create_group_cubit.dart';
import '../../cubits/create_group_state.dart';


const _dialogMaxWidth = 520.0;
const _avatarRadius = 22.0;

class CreateGroupDialogView extends StatelessWidget {
  const CreateGroupDialogView({
    super.key,
    required this.nameController,
    required this.genreController,
    required this.link1Controller,
    required this.link2Controller,
    required this.onCancel,
    required this.onSubmit,
    required this.canSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController genreController;
  final TextEditingController link1Controller;
  final TextEditingController link2Controller;
  final VoidCallback onCancel;
  final VoidCallback? onSubmit;
  final bool canSubmit;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final cubit = context.read<CreateGroupCubit>();

    return BlocBuilder<CreateGroupCubit, CreateGroupState>(
      builder: (context, state) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.groups_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(loc.rehearsalsSidebarCreateGroupTitle),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
            child: SingleChildScrollView(
              child: _DialogContent(
                state: state,
                nameController: nameController,
                genreController: genreController,
                link1Controller: link1Controller,
                link2Controller: link2Controller,
                onShowPhotoOptions: () => _showPhotoOptions(context, cubit, state),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: onCancel, child: Text(loc.cancel)),
            FilledButton(
              onPressed: canSubmit && !state.isPickingPhoto ? onSubmit : null,
              child: Text(loc.create),
            ),
          ],
        );
      },
    );
  }

  void _showPhotoOptions(
    BuildContext context,
    CreateGroupCubit cubit,
    CreateGroupState state,
  ) {
    showModalBottomSheet<void>(
      context: context,
      builder:
          (context) => _PhotoOptionsSheet(
            hasPhoto: state.photoBytes != null,
            onPickGallery: () => cubit.pickPhoto(ImageSource.gallery),
            onPickCamera: () => cubit.pickPhoto(ImageSource.camera),
            onRemove: cubit.clearPhoto,
          ),
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent({
    required this.state,
    required this.nameController,
    required this.genreController,
    required this.link1Controller,
    required this.link2Controller,
    required this.onShowPhotoOptions,
  });

  final CreateGroupState state;
  final TextEditingController nameController;
  final TextEditingController genreController;
  final TextEditingController link1Controller;
  final TextEditingController link2Controller;
  final VoidCallback onShowPhotoOptions;

  @override
  Widget build(BuildContext context) {
    const gapSmall = SizedBox(height: 8);
    const gapMedium = SizedBox(height: 12);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PhotoTile(
          state: state,
          onTap: state.isPickingPhoto ? null : onShowPhotoOptions,
        ),
        gapSmall,
        _CreateGroupTextField(
          controller: nameController,
          labelText: 'Nombre',
          hintText: 'Ej. Banda X',
          autofocus: true,
        ),
        gapMedium,
        _CreateGroupTextField(
          controller: genreController,
          labelText: 'Género',
          hintText: 'Ej. Rock / Jazz',
        ),
        gapMedium,
        _CreateGroupTextField(
          controller: link1Controller,
          labelText: 'Enlace 1',
          hintText: 'https://...',
          keyboardType: TextInputType.url,
        ),
        gapMedium,
        _CreateGroupTextField(
          controller: link2Controller,
          labelText: 'Enlace 2',
          hintText: 'https://...',
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.state, required this.onTap});

  final CreateGroupState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: _avatarRadius,
        backgroundImage:
            state.photoBytes == null ? null : MemoryImage(state.photoBytes!),
        child:
            state.photoBytes == null ? const Icon(Icons.groups_outlined) : null,
      ),
      title: const Text('Foto del grupo'),
      subtitle: Text(
        state.photoBytes == null ? 'Opcional' : 'Seleccionada',
      ),
      trailing:
          state.isPickingPhoto
              ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.edit_outlined),
      onTap: onTap,
    );
  }
}

class _CreateGroupTextField extends StatelessWidget {
  const _CreateGroupTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.keyboardType,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final TextInputType? keyboardType;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText, hintText: hintText),
      keyboardType: keyboardType,
      autofocus: autofocus,
    );
  }
}

class _PhotoOptionsSheet extends StatelessWidget {
  const _PhotoOptionsSheet({
    required this.hasPhoto,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onRemove,
  });

  final bool hasPhoto;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PhotoOptionTile(
            icon: Icons.photo_library_outlined,
            title: 'Seleccionar de la galería',
            onTap: onPickGallery,
          ),
          _PhotoOptionTile(
            icon: Icons.photo_camera_outlined,
            title: 'Usar la cámara',
            onTap: onPickCamera,
          ),
          if (hasPhoto)
            _PhotoOptionTile(
              icon: Icons.delete_outline,
              title: 'Quitar foto',
              onTap: onRemove,
            ),
        ],
      ),
    );
  }
}

class _PhotoOptionTile extends StatelessWidget {
  const _PhotoOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}
