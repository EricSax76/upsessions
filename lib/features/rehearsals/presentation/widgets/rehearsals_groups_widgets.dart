// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RehearsalsGroupsHeader extends StatelessWidget {
  const RehearsalsGroupsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ensayos', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          'Tus grupos activos para organizar ensayos.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class RehearsalsGroupsActions extends StatelessWidget {
  const RehearsalsGroupsActions({
    super.key,
    required this.onGoToGroup,
    required this.onCreateGroup,
  });

  final VoidCallback onGoToGroup;
  final VoidCallback onCreateGroup;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        OutlinedButton.icon(
          onPressed: onGoToGroup,
          icon: const Icon(Icons.login_outlined),
          label: const Text('Ir a un grupo'),
        ),
        FilledButton.icon(
          onPressed: onCreateGroup,
          icon: const Icon(Icons.group_add_outlined),
          label: const Text('Nuevo grupo'),
        ),
      ],
    );
  }
}

class RehearsalsGroupsEmptyState extends StatelessWidget {
  const RehearsalsGroupsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.groups_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aun no tienes grupos de ensayos. Crea uno nuevo.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.groupName,
    required this.role,
    required this.onTap,
  });

  final String groupName;
  final String role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(context, role);
    final initials = _initialsFromName(groupName);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.15),
                child: Text(
                  initials,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rol: ${_roleLabel(role)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _roleLabel(role),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

String _roleLabel(String role) {
  switch (role) {
    case 'owner':
      return 'Owner';
    case 'admin':
      return 'Admin';
    default:
      return 'Miembro';
  }
}

Color _roleColor(BuildContext context, String role) {
  final scheme = Theme.of(context).colorScheme;
  switch (role) {
    case 'owner':
      return scheme.secondary;
    case 'admin':
      return scheme.tertiary;
    default:
      return scheme.primary;
  }
}

String _initialsFromName(String value) {
  final cleaned = value.trim();
  if (cleaned.isEmpty) return 'G';
  final parts = cleaned.split(RegExp(r'\s+'));
  if (parts.length == 1) return _firstLetter(parts.first);
  final first = _firstLetter(parts.first);
  final last = _firstLetter(parts.last);
  return '$first$last';
}

String _firstLetter(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';
  return trimmed.substring(0, 1).toUpperCase();
}

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
    final canSubmit = _name.text.trim().isNotEmpty && !_pickingPhoto;
    return AlertDialog(
      title: const Text('Crear grupo'),
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
          child: const Text('Cancelar'),
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
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
