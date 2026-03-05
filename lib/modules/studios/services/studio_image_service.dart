import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StudioImageService {
  StudioImageService({required FirebaseStorage storage})
      : _storage = storage;

  final FirebaseStorage _storage;
  final ImagePicker _picker = ImagePicker();

  Future<String?> uploadStudioLogo(String studioId) async {
    return _uploadImage(
      path: 'studios/$studioId/logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      metadata: {'studioId': studioId, 'type': 'logo'},
    );
  }

  Future<String?> uploadStudioBanner(String studioId) async {
    return _uploadImage(
      path: 'studios/$studioId/banner_${DateTime.now().millisecondsSinceEpoch}.jpg',
      metadata: {'studioId': studioId, 'type': 'banner'},
    );
  }

  Future<List<XFile>> pickRoomPhotos() async {
    return _picker.pickMultiImage(maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
  }

  Future<String?> uploadRoomPhoto(String studioId, String roomId, XFile image) async {
    try {
      final path = 'studios/$studioId/rooms/$roomId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(path);
      final data = await image.readAsBytes();
      final snapshot = await ref.putData(
        data,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'studioId': studioId, 'roomId': roomId, 'type': 'room_photo'},
        ),
      );
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading room photo: $e');
      return null;
    }
  }

  Future<String?> _uploadImage({
    required String path,
    required Map<String, String> metadata,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      final Reference ref = _storage.ref().child(path);
      final Uint8List imageData = await image.readAsBytes();

      final UploadTask uploadTask = ref.putData(
        imageData,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: metadata,
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }
}
