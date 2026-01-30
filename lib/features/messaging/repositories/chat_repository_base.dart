import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/cloud_functions_service.dart';
import 'package:upsessions/modules/auth/repositories/auth_repository.dart';

class ChatRepositoryBase {
  ChatRepositoryBase({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
    CloudFunctionsService? cloudFunctionsService,
  }) : firestore = firestore ?? FirebaseFirestore.instance,
       authRepository = authRepository ?? AuthRepository(),
       cloudFunctionsService = cloudFunctionsService ?? CloudFunctionsService();

  final FirebaseFirestore firestore;
  final AuthRepository authRepository;
  final CloudFunctionsService cloudFunctionsService;

  void log(String message) {
    if (!kDebugMode) return;
    debugPrint('[ChatRepository] $message');
  }

  String requireUid() {
    final uid = authRepository.currentUser?.id;
    if (uid == null) {
      throw Exception('Debes iniciar sesión.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> threads() =>
      firestore.collection('chat_threads');

  CollectionReference<Map<String, dynamic>> userThreadIndex(String uid) =>
      firestore.collection('musicians').doc(uid).collection('threads');

  DocumentReference<Map<String, dynamic>> threadDoc(String threadId) =>
      threads().doc(threadId);

  CollectionReference<Map<String, dynamic>> messages(String threadId) =>
      threadDoc(threadId).collection('messages');

  DocumentReference<Map<String, dynamic>> chatCounters(String uid) => firestore
      .collection('musicians')
      .doc(uid)
      .collection('counters')
      .doc('chat');

  Query<Map<String, dynamic>> threadsForUser(String uid) => threads()
      .where('participants', arrayContains: uid)
      .orderBy('lastMessageAt', descending: true);
}
