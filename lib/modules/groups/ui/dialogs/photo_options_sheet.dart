import 'package:flutter/material.dart';

class PhotoOptionsSheet extends StatelessWidget {
  const PhotoOptionsSheet({
    super.key,
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
