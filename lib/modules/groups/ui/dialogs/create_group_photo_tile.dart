import 'package:flutter/material.dart';

import '../../cubits/create_group_state.dart';

const _avatarRadius = 22.0;

class CreateGroupPhotoTile extends StatelessWidget {
  const CreateGroupPhotoTile({
    super.key,
    required this.state,
    required this.onTap,
  });

  final CreateGroupState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: _avatarRadius,
        backgroundImage: state.photoBytes == null
            ? null
            : MemoryImage(state.photoBytes!),
        child: state.photoBytes == null
            ? const Icon(Icons.groups_outlined)
            : null,
      ),
      title: const Text('Foto del grupo'),
      subtitle: Text(state.photoBytes == null ? 'Opcional' : 'Seleccionada'),
      trailing: state.isPickingPhoto
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
