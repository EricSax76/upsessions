import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/cloud_functions_service.dart';
import 'package:upsessions/modules/auth/data/auth_repository.dart';
import '../domain/chat_message.dart';
import '../domain/chat_thread.dart';

class ChatRepository {
  ChatRepository({
    FirebaseFirestore? firestore,
    AuthRepository? authRepository,
    CloudFunctionsService? cloudFunctionsService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository ?? AuthRepository(),
        _cloudFunctionsService = cloudFunctionsService ?? CloudFunctionsService();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final CloudFunctionsService _cloudFunctionsService;

  Future<List<ChatThread>> fetchThreads() async {
    final currentEmail = _authRepository.currentUser?.email;
    if (currentEmail == null) {
      return const [];
    }
    final snapshot = await _firestore
        .collection('chat_threads')
        .where('participants', arrayContains: currentEmail)
        .orderBy('lastMessageAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => _mapThread(doc, currentEmail)).toList();
  }

  Future<List<ChatMessage>> fetchMessages(String threadId) async {
    final currentEmail = _authRepository.currentUser?.email;
    final snapshot = await _firestore
        .collection('chat_threads')
        .doc(threadId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .get();
    return snapshot.docs.map((doc) => _mapMessage(doc, currentEmail)).toList();
  }

  Future<ChatMessage> sendMessage(String threadId, String body) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para enviar mensajes.');
    }
    final messagesCollection = _firestore.collection('chat_threads').doc(threadId).collection('messages');
    final now = DateTime.now();
    final docRef = messagesCollection.doc();
    final payload = {
      'sender': user.email,
      'body': body,
      'sentAt': Timestamp.fromDate(now),
    };
    await docRef.set(payload);
    final lastMessage = {
      'id': docRef.id,
      ...payload,
    };
    await _firestore.collection('chat_threads').doc(threadId).update({
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(now),
    });
    await _cloudFunctionsService.notifyChatMessage(threadId: threadId, sender: user.email, body: body);
    return ChatMessage(
      id: docRef.id,
      sender: user.email,
      body: body,
      sentAt: now,
      isMine: true,
    );
  }

  ChatThread _mapThread(QueryDocumentSnapshot<Map<String, dynamic>> doc, String currentEmail) {
    final data = doc.data();
    final lastMessageMap = (data['lastMessage'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    return ChatThread(
      id: doc.id,
      participants: _stringList(data['participants']),
      lastMessage: _mapMessageFromMap(lastMessageMap, currentEmail),
      unreadCount: _unreadCount(data['unreadCounts'], currentEmail),
    );
  }

  ChatMessage _mapMessage(QueryDocumentSnapshot<Map<String, dynamic>> doc, String? currentEmail) {
    final data = doc.data();
    return ChatMessage(
      id: doc.id,
      sender: (data['sender'] ?? '') as String,
      body: (data['body'] ?? '') as String,
      sentAt: _parseTimestamp(data['sentAt']),
      isMine: data['sender'] == currentEmail,
    );
  }

  ChatMessage _mapMessageFromMap(Map<String, dynamic> data, String currentEmail) {
    return ChatMessage(
      id: (data['id'] ?? '') as String,
      sender: (data['sender'] ?? '') as String,
      body: (data['body'] ?? '') as String,
      sentAt: _parseTimestamp(data['sentAt']),
      isMine: data['sender'] == currentEmail,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is Iterable) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }

  static int _unreadCount(dynamic raw, String currentEmail) {
    if (raw is Map<String, dynamic>) {
      final value = raw[currentEmail];
      if (value is num) {
        return value.toInt();
      }
    }
    return 0;
  }
}
