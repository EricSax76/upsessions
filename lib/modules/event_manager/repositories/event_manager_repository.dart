import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/event_manager_dto.dart';
import '../models/event_manager_entity.dart';

class EventManagerRepository {
  EventManagerRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<EventManagerDto> get _collection => _firestore
      .collection('event_managers')
      .withConverter(
        fromFirestore: EventManagerDto.fromDocument,
        toFirestore: (EventManagerDto dto, _) => dto.toJson(),
      );

  Future<EventManagerEntity?> fetchById(String id) async {
    final snapshot = await _collection.doc(id).get();
    if (!snapshot.exists) {
      return null;
    }

    final dto = snapshot.data();
    return dto?.toEntity();
  }

  Future<EventManagerEntity?> fetchByOwnerId(String ownerId) async {
    final querySnapshot = await _collection
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return querySnapshot.docs.first.data().toEntity();
  }

  Future<void> create(EventManagerEntity entity) async {
    final dto = EventManagerDto.fromEntity(entity);
    await _collection.doc(dto.id).set(dto);
  }

  Future<void> update(EventManagerEntity entity) async {
    final dto = EventManagerDto.fromEntity(entity);
    await _collection.doc(dto.id).update(dto.toJson());
  }

  Future<String> uploadLogo(String managerId, File file) async {
    final bytes = await file.readAsBytes();
    return uploadLogoBytes(
      managerId,
      bytes,
      fileExtension: _extensionFromPath(file.path),
    );
  }

  Future<String> uploadLogoBytes(
    String managerId,
    Uint8List bytes, {
    String fileExtension = 'jpg',
  }) async {
    final extension = _sanitizeExtension(fileExtension);
    final ref = _storage.ref().child(
      'event_managers/$managerId/logo.$extension',
    );
    final snapshot = await ref.putData(
      bytes,
      SettableMetadata(contentType: _contentTypeForExtension(extension)),
    );
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadBanner(String managerId, File file) async {
    final ref = _storage.ref().child('event_managers/$managerId/banner.jpg');
    final snapshot = await ref.putFile(file);
    return await snapshot.ref.getDownloadURL();
  }
}

String _extensionFromPath(String path) {
  final dotIndex = path.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == path.length - 1) {
    return 'jpg';
  }
  return path.substring(dotIndex + 1).toLowerCase();
}

String _sanitizeExtension(String extension) {
  final cleaned = extension.trim().toLowerCase().replaceAll('.', '');
  if (cleaned.isEmpty) return 'jpg';
  return cleaned;
}

String _contentTypeForExtension(String extension) {
  switch (extension) {
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    case 'heic':
    case 'heif':
      return 'image/heic';
    case 'jpeg':
    case 'jpg':
    default:
      return 'image/jpeg';
  }
}
