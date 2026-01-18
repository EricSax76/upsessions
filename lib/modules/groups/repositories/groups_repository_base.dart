import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../auth/data/auth_repository.dart';

class GroupsRepositoryBase {
  GroupsRepositoryBase({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _authRepository = authRepository ?? AuthRepository();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  FirebaseFirestore get firestore => _firestore;
  AuthRepository get authRepository => _authRepository;

  void logFirestore(String message) {
    if (!kDebugMode) return;
    debugPrint('[Firestore] $message');
  }

  Stream<T> logStream<T>(String label, Stream<T> stream) {
    return stream.handleError((error, stackTrace) {
      logFirestore('$label error: $error');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
    });
  }

  Future<T> logFuture<T>(String label, Future<T> future) async {
    try {
      return await future;
    } catch (error, stackTrace) {
      logFirestore('$label error: $error');
      if (kDebugMode) {
        debugPrintStack(stackTrace: stackTrace);
      }
      rethrow;
    }
  }

  String requireUid() {
    final uid = _authRepository.currentUser?.id;
    if (uid == null) {
      throw Exception('Debes iniciar sesión.');
    }
    return uid;
  }

  Future<String> requireMusicianUid() async {
    final uid = requireUid();
    final ref = _firestore.collection('musicians').doc(uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'ownerId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> groups() =>
      _firestore.collection('groups');

  DocumentReference<Map<String, dynamic>> groupDoc(String groupId) =>
      groups().doc(groupId);

  CollectionReference<Map<String, dynamic>> members(String groupId) =>
      groupDoc(groupId).collection('members');

  CollectionReference<Map<String, dynamic>> invites(String groupId) =>
      groupDoc(groupId).collection('invites');
}
