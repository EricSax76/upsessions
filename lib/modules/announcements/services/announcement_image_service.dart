import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class AnnouncementImageService {
  AnnouncementImageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Subir imagen de anuncio a Firebase Storage
  Future<String?> uploadImage(XFile image, {String? announcementId}) async {
    try {
      final id = announcementId ?? DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'announcement_${id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('announcements/images/$fileName');

      debugPrint('📤 [AnnouncementImage] Subiendo imagen: $fileName');

      final Uint8List imageData = await image.readAsBytes();
      
      final UploadTask uploadTask = ref.putData(
        imageData,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'originalName': image.name,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      debugPrint('✅ [AnnouncementImage] Imagen subida: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ [AnnouncementImage] Error al subir imagen: $e');
      rethrow;
    }
  }

  /// Eliminar imagen de anuncio
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('🗑️ [AnnouncementImage] Imagen eliminada: $imageUrl');
    } catch (e) {
      debugPrint('❌ [AnnouncementImage] Error al eliminar imagen: $e');
    }
  }
}
