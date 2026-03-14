import 'package:flutter/material.dart';

import '../../cubits/create_group_state.dart';
import 'create_group_photo_tile.dart';
import 'create_group_text_field.dart';

class CreateGroupDialogContent extends StatelessWidget {
  const CreateGroupDialogContent({
    super.key,
    required this.state,
    required this.nameController,
    required this.genreController,
    required this.link1Controller,
    required this.link2Controller,
    required this.descriptionController,
    required this.cityController,
    required this.onShowPhotoOptions,
  });

  final CreateGroupState state;
  final TextEditingController nameController;
  final TextEditingController genreController;
  final TextEditingController link1Controller;
  final TextEditingController link2Controller;
  final TextEditingController descriptionController;
  final TextEditingController cityController;
  final VoidCallback onShowPhotoOptions;

  @override
  Widget build(BuildContext context) {
    const gapSmall = SizedBox(height: 8);
    const gapMedium = SizedBox(height: 12);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CreateGroupPhotoTile(
          state: state,
          onTap: state.isPickingPhoto ? null : onShowPhotoOptions,
        ),
        gapSmall,
        CreateGroupTextField(
          controller: nameController,
          labelText: 'Nombre',
          hintText: 'Ej. Banda X',
          autofocus: true,
        ),
        gapMedium,
        CreateGroupTextField(
          controller: genreController,
          labelText: 'Género',
          hintText: 'Ej. Rock / Jazz',
        ),
        gapMedium,
        CreateGroupTextField(
          controller: descriptionController,
          labelText: 'Descripción del grupo',
          hintText: 'Historia, estilo, trayectoria...',
          maxLines: 3,
        ),
        gapMedium,
        CreateGroupTextField(
          controller: cityController,
          labelText: 'Ciudad base',
          hintText: 'Ej. Madrid',
        ),
        gapMedium,
        CreateGroupTextField(
          controller: link1Controller,
          labelText: 'Enlace 1',
          hintText: 'https://...',
          keyboardType: TextInputType.url,
        ),
        gapMedium,
        CreateGroupTextField(
          controller: link2Controller,
          labelText: 'Enlace 2',
          hintText: 'https://...',
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
}
