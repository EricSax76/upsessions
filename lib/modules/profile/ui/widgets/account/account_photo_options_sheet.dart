import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountPhotoOptionsSheet extends StatelessWidget {
  const AccountPhotoOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Seleccionar de la galería'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Usar la cámara'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
        ],
      ),
    );
  }
}
