import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Servicio para gestionar la subida de imágenes a Firebase Storage
class ImageUploadService {
  ImageUploadService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;
  final ImagePicker _picker = ImagePicker();

  /// Selecciona y sube una imagen banner para un evento
  /// Retorna la URL de descarga de la imagen o null si se cancela
  Future<String?> uploadEventBanner(String eventId) async {
    try {
      debugPrint('🎨 [ImageUpload] Iniciando selección de imagen para evento: $eventId');
      
      // Seleccionar imagen de la galería
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint('⚠️ [ImageUpload] Usuario canceló la selección de imagen');
        return null; // Usuario canceló la selección
      }

      debugPrint('✅ [ImageUpload] Imagen seleccionada: ${image.name}, tamaño: ${await image.length()} bytes');

      // Crear referencia en Storage
      final String fileName = 'event_${eventId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('events/banners/$fileName');
      
      debugPrint('📤 [ImageUpload] Iniciando subida a: events/banners/$fileName');

      // Leer los bytes de la imagen (funciona en web y móvil)
      final Uint8List imageData = await image.readAsBytes();
      debugPrint('📊 [ImageUpload] Bytes leídos: ${imageData.length}');

      // Subir archivo usando bytes
      final UploadTask uploadTask = ref.putData(
        imageData,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'eventId': eventId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalName': image.name,
          },
        ),
      );

      // Monitorear progreso
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('📈 [ImageUpload] Progreso: ${progress.toStringAsFixed(1)}%');
      });

      // Esperar a que se complete la subida
      final TaskSnapshot snapshot = await uploadTask;
      debugPrint('✅ [ImageUpload] Subida completada');

      // Obtener URL de descarga
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('🔗 [ImageUpload] URL obtenida: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      // Mostrar error detallado
      debugPrint('❌ [ImageUpload] Error al subir imagen: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow; // Re-lanzar el error para que se maneje en la UI
    }
  }

  /// Elimina una imagen banner de un evento
  Future<bool> deleteEventBanner(String imageUrl) async {
    try {
      debugPrint('🗑️ [ImageUpload] Eliminando banner: $imageUrl');
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      debugPrint('✅ [ImageUpload] Banner eliminado exitosamente');
      return true;
    } catch (e) {
      debugPrint('❌ [ImageUpload] Error al eliminar banner: $e');
      return false;
    }
  }
}
