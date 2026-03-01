import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/event_manager_dto.dart';
import '../models/event_manager_entity.dart';

class EventManagerRepository {
  EventManagerRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<EventManagerDto> get _collection =>
      _firestore.collection('event_managers').withConverter(
            fromFirestore: EventManagerDto.fromDocument,
            toFirestore: (EventManagerDto dto, _) => dto.toJson(),
          );

  Future<EventManagerEntity?> fetchByOwnerId(String ownerId) async {
    final querySnapshot =
        await _collection.where('ownerId', isEqualTo: ownerId).limit(1).get();

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
    final ref = _storage.ref().child('event_managers/$managerId/logo.jpg');
    final snapshot = await ref.putFile(file);
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadBanner(String managerId, File file) async {
    final ref = _storage.ref().child('event_managers/$managerId/banner.jpg');
    final snapshot = await ref.putFile(file);
    return await snapshot.ref.getDownloadURL();
  }
}
