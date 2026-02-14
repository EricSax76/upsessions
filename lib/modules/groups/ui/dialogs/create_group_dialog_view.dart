import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upsessions/l10n/app_localizations.dart';

import '../../controllers/create_group_dialog_controller.dart';
import '../../models/create_group_draft.dart';

const _dialogMaxWidth = 520.0;
const _avatarRadius = 22.0;

class CreateGroupDialogView extends StatelessWidget {
  const CreateGroupDialogView({
    super.key,
    required this.controller,
    required this.onCancel,
    required this.onSubmit,
  });

  final CreateGroupDialogController controller;
  final VoidCallback onCancel;
  final ValueChanged<CreateGroupDraft> onSubmit;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final canSubmit = controller.canSubmit;
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
                controller: controller,
                onShowPhotoOptions: () => _showPhotoOptions(context),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: onCancel, child: Text(loc.cancel)),
            FilledButton(
              onPressed: canSubmit
                  ? () => onSubmit(controller.buildDraft())
                  : null,
              child: Text(loc.create),
            ),
          ],
        );
      },
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _PhotoOptionsSheet(
        hasPhoto: controller.photoBytes != null,
        onPickGallery: () => controller.pickPhoto(ImageSource.gallery),
        onPickCamera: () => controller.pickPhoto(ImageSource.camera),
        onRemove: controller.clearPhoto,
      ),
    );
  }
}

class _DialogContent extends StatelessWidget {
  const _DialogContent({
    required this.controller,
    required this.onShowPhotoOptions,
  });

  final CreateGroupDialogController controller;
  final VoidCallback onShowPhotoOptions;

  @override
  Widget build(BuildContext context) {
    const gapSmall = SizedBox(height: 8);
    const gapMedium = SizedBox(height: 12);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PhotoTile(
          controller: controller,
          onTap: controller.isPickingPhoto ? null : onShowPhotoOptions,
        ),
        gapSmall,
        _CreateGroupTextField(
          controller: controller.nameController,
          labelText: 'Nombre',
          hintText: 'Ej. Banda X',
          autofocus: true,
        ),
        gapMedium,
        _CreateGroupTextField(
          controller: controller.genreController,
          labelText: 'Género',
          hintText: 'Ej. Rock / Jazz',
        ),
        gapMedium,
        _CreateGroupTextField(
          controller: controller.link1Controller,
          labelText: 'Enlace 1',
          hintText: 'https://...',
          keyboardType: TextInputType.url,
        ),
        gapMedium,
        _CreateGroupTextField(
          controller: controller.link2Controller,
          labelText: 'Enlace 2',
          hintText: 'https://...',
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.controller, required this.onTap});

  final CreateGroupDialogController controller;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: _avatarRadius,
        backgroundImage: controller.photoBytes == null
            ? null
            : MemoryImage(controller.photoBytes!),
        child: controller.photoBytes == null
            ? const Icon(Icons.groups_outlined)
            : null,
      ),
      title: const Text('Foto del grupo'),
      subtitle: Text(
        controller.photoBytes == null ? 'Opcional' : 'Seleccionada',
      ),
      trailing: controller.isPickingPhoto
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
