import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:upsessions/l10n/app_localizations.dart';
import '../../../services/studio_image_service.dart';
import '../../../../../core/locator/locator.dart';
import 'photo_thumb.dart';

/// Par (archivo, bytes) para previsualizar fotos antes de subirlas.
/// Los bytes se leen al momento del pick para que [Image.memory] funcione
/// en todas las plataformas (incluida Web, donde [Image.file] no está soportado).
typedef _PendingPhoto = ({XFile file, Uint8List bytes});

/// Selector de fotos con previsualización.
///
/// Estado interno: fotos ya guardadas ([initialPhotos]) + fotos nuevas pendientes.
/// Exponer [uploadAndGetPhotos] para que el padre obtenga las URLs finales al guardar.
class PhotoPickerSection extends StatefulWidget {
  const PhotoPickerSection({super.key, required this.initialPhotos});

  final List<String> initialPhotos;

  @override
  State<PhotoPickerSection> createState() => PhotoPickerSectionState();
}

class PhotoPickerSectionState extends State<PhotoPickerSection> {
  final _imageService = locate<StudioImageService>();

  late List<String> _existingPhotos;
  final List<_PendingPhoto> _pendingPhotos = [];

  @override
  void initState() {
    super.initState();
    _existingPhotos = List.from(widget.initialPhotos);
  }

  Future<void> _pick() async {
    final picked = await _imageService.pickRoomPhotos();
    for (final file in picked) {
      final bytes = await file.readAsBytes();
      setState(() => _pendingPhotos.add((file: file, bytes: bytes)));
    }
  }

  /// Sube las fotos pendientes y devuelve la lista final de URLs.
  Future<List<String>> uploadAndGetPhotos({
    required String studioId,
    required String roomId,
  }) async {
    final newUrls = <String>[];
    for (final p in _pendingPhotos) {
      final url = await _imageService.uploadRoomPhoto(studioId, roomId, p.file);
      if (url != null) newUrls.add(url);
    }
    return [..._existingPhotos, ...newUrls];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final hasPhotos = _existingPhotos.isNotEmpty || _pendingPhotos.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.roomFormPhotosTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (hasPhotos)
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._existingPhotos.map(
                  (url) => PhotoThumb(
                    child: Image.network(url, fit: BoxFit.cover),
                    onRemove: () => setState(() => _existingPhotos.remove(url)),
                  ),
                ),
                ..._pendingPhotos.map(
                  (p) => PhotoThumb(
                    child: Image.memory(p.bytes, fit: BoxFit.cover),
                    onRemove: () => setState(() => _pendingPhotos.remove(p)),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pick,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(loc.roomFormAttachPhotos),
        ),
      ],
    );
  }
}
