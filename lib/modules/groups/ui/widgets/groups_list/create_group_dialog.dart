import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upsessions/l10n/app_localizations.dart';

class CreateGroupDraft {
  const CreateGroupDraft({
    required this.name,
    required this.genre,
    required this.link1,
    required this.link2,
    required this.photoBytes,
    required this.photoFileExtension,
  });

  final String name;
  final String genre;
  final String link1;
  final String link2;
  final Uint8List? photoBytes;
  final String? photoFileExtension;
}

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _name = TextEditingController();
  final _genre = TextEditingController();
  final _link1 = TextEditingController();
  final _link2 = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _photoBytes;
  String? _photoExtension;
  bool _pickingPhoto = false;

  @override
  void dispose() {
    _name.dispose();
    _genre.dispose();
    _link1.dispose();
    _link2.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_pickingPhoto) return;
    setState(() => _pickingPhoto = true);
    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxHeight: 1600,
        maxWidth: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoExtension = _extensionFromName(file.name);
      });
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Seleccionar de la galería'),
              onTap: () {
                Navigator.of(context).pop();
                _pickPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Usar la cámara'),
              onTap: () {
                Navigator.of(context).pop();
                _pickPhoto(ImageSource.camera);
              },
            ),
            if (_photoBytes != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Quitar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _photoBytes = null;
                    _photoExtension = null;
                  });
                },
              ),
          ],
        ),
      ),
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
    final loc = AppLocalizations.of(context);
    final canSubmit = _name.text.trim().isNotEmpty && !_pickingPhoto;
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
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 22,
                  backgroundImage: _photoBytes == null
                      ? null
                      : MemoryImage(_photoBytes!),
                  child: _photoBytes == null
                      ? const Icon(Icons.groups_outlined)
                      : null,
                ),
                title: const Text('Foto del grupo'),
                subtitle: Text(
                  _photoBytes == null ? 'Opcional' : 'Seleccionada',
                ),
                trailing: _pickingPhoto
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.edit_outlined),
                onTap: _pickingPhoto ? null : _showPhotoOptions,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Ej. Banda X',
                ),
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _genre,
                decoration: const InputDecoration(
                  labelText: 'Género',
                  hintText: 'Ej. Rock / Jazz',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _link1,
                decoration: const InputDecoration(
                  labelText: 'Enlace 1',
                  hintText: 'https://...',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _link2,
                decoration: const InputDecoration(
                  labelText: 'Enlace 2',
                  hintText: 'https://...',
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        FilledButton(
          onPressed: canSubmit
              ? () => Navigator.of(context).pop(
                  CreateGroupDraft(
                    name: _name.text.trim(),
                    genre: _genre.text.trim(),
                    link1: _link1.text.trim(),
                    link2: _link2.text.trim(),
                    photoBytes: _photoBytes,
                    photoFileExtension: _photoExtension,
                  ),
                )
              : null,
          child: Text(loc.create),
        ),
      ],
    );
  }
}
